//
//  ViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/16/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthUI
import AWSUserPoolsSignIn
import AWSFacebookSignIn
import AWSGoogleSignIn
import AWSCore
import AWSCognito
import AWSCognitoIdentityProviderASF
import GoogleSignIn
import FacebookCore
//import SideMenu

var cellSwitches: [AppsTableViewCell] = []
var apps: [Apps] = []

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var appsTableView: UITableView!
    @IBOutlet weak var qrCodeButton: UIButton!
    var identityProvider:String!
    var credentialsManager = CredentialsManager.sharedInstance
    var datasetManager = Dataset.sharedInstance
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet var uploadImageButton: UIBarButtonItem!
    var token: String!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("----in view did load----")
//        sideMenuViewController = storyboard!.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
//        sideMenuViewController.view.frame = UIScreen.main.bounds
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            appsTableView.refreshControl = refreshControl
        } else {
            appsTableView.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshAppData(_:)), for: .valueChanged)
        setupView()
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("----in view will appear----")
//        if(isMenuOpened == true){
//            isMenuOpened = false
//            sideMenuViewController.willMove(toParentViewController: nil)
//            sideMenuViewController.view.removeFromSuperview()
//            sideMenuViewController.removeFromParentViewController()
//        }
      //  cellSwitches = []
        self.tabBarController?.tabBar.isHidden = false
        presentAuthUIViewController()
        appsTableView.reloadData()
      // createQRCode(self)
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
    
    func presentAuthUIViewController() {
        print("presentAuthUIViewController()")
        let config = AWSAuthUIConfiguration()
        config.enableUserPoolsUI = true
        config.addSignInButtonView(class: AWSFacebookSignInButton.self)
        config.addSignInButtonView(class: AWSGoogleSignInButton.self)
        config.logoImage = UIImage(named: "launch_logo")
        config.backgroundColor = UIColor.white
        config.font = UIFont (name: "Helvetica Neue", size: 14)
        config.canCancel = true
        
        print("in present auth ui method")
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            AWSAuthUIViewController
                .presentViewController(with: self.navigationController!,
                                       configuration: config,
                                       completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                        if error != nil {
                                            print("Error occurred: \(String(describing: error))")
                                        } else {
                                            // Sign in successful.
                                        }
                })
        }
        else {
            self.navigationController?.popToRootViewController(animated: true)// Initialize the Cognito Sync client
            credentialsManager.createCredentialsProvider()
            //credentialsManager.credentialsProvider.getIdentityId()
            credentialsManager.credentialsProvider.identityProvider.logins().continueWith { (task: AWSTask!) -> AnyObject! in
                
                if (task.error != nil) {
                    print("ERROR: Unable to get logins. Description: \(task.error!)")
                    
                } else {
                    if task.result != nil{
                    }
                    self.credentialsManager.credentialsProvider.getIdentityId().continueWith { (task: AWSTask!) -> AnyObject! in
                        
                        if (task.error != nil) {
                            print("ERROR: Unable to get ID. Error description: \(task.error!)")
                            
                        } else {
                            print("Signed in user with the following ID:")
                            let id = task.result! as? String
                            self.credentialsManager.setIdentityID(id: id!)
                            print(self.credentialsManager.identityID)
                            self.datasetManager.createDataset()
                            self.fetchAppData()
                            if AWSFacebookSignInProvider.sharedInstance().isLoggedIn {
                                print("facebook sign in confirmed")
                                self.navigationItem.leftBarButtonItem = nil
                                let params: String = "name,email,picture"
                                self.getFBUserInfo(params: params, dataset: self.datasetManager.dataset)
                            } else {
                                self.profileImage.image = UIImage(named: "launch_logo")
                                self.navigationItem.leftBarButtonItem = self.uploadImageButton
                                //query the db for an image
                            }
                        }
                        return nil
                    }
                    
                    return nil
                }
                return nil
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadApps(){
        print("loadApps()")
        loadAppsFromDB()
    }
    
    ////////////////////////////// BEGINNING OF JSON ///////////////////////////////////
    
    // TomMiller 2018/06/27 - Added struct to interact with JSON
    struct JsonApp: Decodable {
        //["{\"accounts\":[{\"cognitoId\":\"us-east-1:bafa67f1-8631-4c47-966d-f9f069b2107c\",\"displayName\":\"tomTweets\",\"platform\":\"Twitter\",\"url\":\"http://www.twitter.com/TomsTwitter\"}]}", ""]
        let accounts: [[String: String]]
    }
    
    var JsonApps = [JsonApp]()
    ////////////////////////////// END OF JSON ///////////////////////////////////
    
    // Tom 2018/04/18
    func loadAppsFromDB() {
        print("RIGHT HERE")
        var returnList: [Apps] = []
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/getUserByID")!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON

        let postString = "{\"user\": {\"cognitoId\": \"\(idString)\"}}"
        print(postString)
        request.httpBody = postString.data(using: String.Encoding.utf8)
        print(request.httpBody)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
        data, response, error in
        if error != nil {
            print("error=\(error)")
            sema.signal()
            return
        } else {
            print("---no error----")
        }
            //////////////////////// New stuff from Tom
            do {
                print("decoding")
                let decoder = JSONDecoder()
                print("getting data")
                let JSONdata = try decoder.decode(JsonApp.self, from: data!)
                //=======
                for index in 0...JSONdata.accounts.count - 1 {
                   let listOfAccountInfo = JSONdata.accounts[index]
                    let displayName = listOfAccountInfo["displayName"]!
                    let platform = listOfAccountInfo["platform"]!
                    let url = listOfAccountInfo["url"]!
                    let cognitoId = listOfAccountInfo["cognitoId"]!
                    print(displayName)
                    print(platform)
                    print(url)
                    print(cognitoId)
                    let app = Apps()
                    app?._userId = cognitoId
                    app?._displayName = displayName
                    app?._platform = platform
                    app?._uRL = url
                    print(app)
                    returnList.append(app!)
                }
                apps = returnList
                sema.signal();
                //=======
            } catch let err {
                print("Err", err)
                apps = returnList
                sema.signal(); // none found TODO: do something better than this shit.
            }
            print("Done")
            /////////////////////////
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        self.appsTableView.reloadData()
    }
    
    func getFBUserInfo(params: String, dataset: AWSCognitoDataset) {
        print("getFBUserInfo()")
        let request = GraphRequest(graphPath: "me", parameters: ["fields":params], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
                case .success(let value):
                    print(value.dictionaryValue ?? "-1")
                    let userID = value.dictionaryValue?["id"] as! String
                    dataset.setString(userID, forKey: "userID")
                    let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(userID)/picture?type=large")
                    if let data = NSData(contentsOf: facebookProfileUrl!) {
                        self.profileImage.image = UIImage(data: data as Data)
                        
                    }
                dataset.setString(value.dictionaryValue?["id"] as? String, forKey: "Facebook")
                self.nameLabel.text = value.dictionaryValue?["name"] as? String
            case .failed(let error):
                print(error)
            }
        }
    }
    
//    @IBAction func menuClicked(_ sender: Any) {
//        print("menuClicked()")
//        if(isMenuOpened){
//            isMenuOpened = false
//            sideMenuViewController.willMove(toParentViewController: nil)
//            sideMenuViewController.view.removeFromSuperview()
//            sideMenuViewController.removeFromParentViewController()
//        }
//        else{
//            isMenuOpened = true
//            self.addChildViewController(sideMenuViewController)
//            self.view.addSubview(sideMenuViewController.view)
//            sideMenuViewController.didMove(toParentViewController: self)
//        }
//        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
//    }
//
    @IBAction func scan(_ sender: Any) {
        let scannerVC = ScannerViewController()
        self.navigationController?.pushViewController(scannerVC, animated: true)
    }
    
    // Goes through the list of table cells that contain the switches for which apps
    // to use in the QR Code being made. It checks their label and UISwitch.
    // If the switch is "On" then it will be included in the QR codes creation.
    @IBAction func createQRCode(_ sender: Any) {
        var jsonStringAsArray = "{\n"
     print("createQRCode()")
        if(cellSwitches.count > 0){
            for index in 0...cellSwitches.count - 1{
                let isSelectedForQRCode = cellSwitches[index].appSwitch.isOn
                let appID = cellSwitches[index].id
                print(appID)
                print(isSelectedForQRCode)
                if (isSelectedForQRCode){
                    for app in apps {
                        if(Int(app._userId!) == appID){
                              jsonStringAsArray += "\"\(app._userId!)\": \"\(app._uRL!)\",\n"
                        } else {
                            print("app not found to make QR code")
                        }
                    }
                }
            }
        } else {
            print("no apps - casnnot create code")
        }
        jsonStringAsArray += "}"
        let result = jsonStringAsArray.replacingLastOccurrenceOfString(",",
                                                              with: "")
        print(result)
        if(datasetManager.dataset != nil){
            datasetManager.dataset.setString(result, forKey: "jsonStringAsArray")
        }
        //qrCodeButton.setImage(generateQRCode(from: result), for: .normal)
        //qrCodeButton.sizeToFit()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        //Convert string to data
        let stringData = string.data(using: String.Encoding.utf8)
        
        //Generate CIImage
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(stringData, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciImage = filter?.outputImage else { return nil }
        
        //Scale image to proper size
        // let scale = CGFloat(size) / ciImage.extent.size.width
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        //Convert to CGImage
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return nil }
        
        //Finally return the UIImage
        return UIImage(cgImage: cgImage)
    }
      
    
    func tableView(_ ExpensesTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableView() return apps.count = \(apps.count)")
        return apps.count
    }
    
    // This is where the table cells on the main page are modeled from.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an object of the dynamic cell “PlainCell”
        let cell:AppsTableViewCell = appsTableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! AppsTableViewCell
        print("Adding to table view now: \(cell)")
        if (!cellSwitches.contains(cell)) {
            cellSwitches.append(cell)
        }
        cell.NameLabel.text = apps[indexPath.row]._displayName
        switch apps[indexPath.row]._platform {
        case "Facebook"?:
            cell.appImage.image = UIImage(named: "fb-icon")
        case "Twitter"?:
            cell.appImage.image = UIImage(named: "twitter_icon")
        case "Instagram"?:
            cell.appImage.image = UIImage(named: "Instagram_icon")
        case "Snapchat"?:
            cell.appImage.image = UIImage(named: "snapchat_icon")
        case "Google+"?:
            cell.appImage.image = UIImage(named: "google_plus_icon")
        case "LinkedIn"?:
            cell.appImage.image = UIImage(named: "linked_in_logo")
        default:
            cell.appImage.image = UIImage(named: "AppIcon")
        }
        
        cell.id = Int(apps[indexPath.row]._userId!)
        //print(indexPath.row)
        if(indexPath.row == apps.count-1){
            print("-----------about to create code----------")
            createQRCode(self)
        }
        return cell
    }
    @IBAction func refreshTableView(_ sender: Any) {
        print("refreshTableView()")
        appsTableView.reloadData()
    }
    
    
    @objc private func refreshAppData(_ sender: Any) {
        // Fetch Weather Data
        print("refreshAppData()")
        fetchAppData()
    }
    
    private func fetchAppData() {
        print("fetchAppData()")
        loadApps()
        self.updateView()
        self.refreshControl.endRefreshing()
//        self.activityIndicatorView.stopAnimating()
    }
    
    private func setupView() {
        print("setUpView()")
        setupTableView()
        setupMessageLabel()
        setupActivityIndicatorView()
    }
    
    private func updateView() {
        print("updateView()")
        let hasApps = apps.count > 0
        print("has apps: \(hasApps)")
        appsTableView.isHidden = false //!hasApps
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        //messageLabel.isHidden = hasApps
        if hasApps {
            appsTableView.reloadData()
          //  messageLabel.isHidden = false
         //   messageLabel.text = "Connected Apps"
        } else {
         //   messageLabel.isHidden = false
         //   messageLabel.text = "No Connected Apps"
        }
        
    }
    
    // MARK: -
    private func setupTableView() {
        print("setuptableView()")
        appsTableView.isHidden = false// true
        activityIndicatorView.isHidden = false
    }
    
    private func setupMessageLabel() {
//        print("setupMessageLabel()")
//        if apps.count > 0 {
//            messageLabel.isHidden = false
//            messageLabel.text = "Connected Apps"
//        } else {
//            messageLabel.isHidden = false
//            messageLabel.text = "No Connected Apps"
//        }
    }
    
    private func setupActivityIndicatorView() {
        activityIndicatorView.startAnimating()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
        
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
    }

    @IBAction func uploadImage(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let qrcodeImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage.image = qrcodeImg
            //send image to DB
        }
        else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension String
{
    func replacingLastOccurrenceOfString(_ searchString: String,
                                         with replacementString: String,
                                         caseInsensitive: Bool = true) -> String
    {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        
        if let range = self.range(of: searchString,
                                  options: options,
                                  range: nil,
                                  locale: nil) {
            
            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
}

