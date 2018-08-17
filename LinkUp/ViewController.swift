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
import GoogleMobileAds
import SwipingCarousel
import CDAlertView

var cellSwitches: [AppsTableViewCell] = []
var apps: [Apps] = []

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SwipingCarouselDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    var profiles: [Profile]!
    fileprivate var allTheCards = Profile.loadCards()
    var bannerView: DFPBannerView!
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var appsTableView: UITableView!
    @IBOutlet weak var qrCodeButton: UIButton!
    var identityProvider:String!
    var credentialsManager = CredentialsManager.sharedInstance
    var datasetManager = Dataset.sharedInstance
    var dataset: AWSCognitoDataset!
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet var uploadImageButton: UIBarButtonItem!
    var token: String!
    let imagePicker = UIImagePickerController()
    var gradient: CAGradientLayer!
    let cellSpacingHeight: CGFloat = 15
    var isCellTapped = false
    var selectedSectionIndex = -1
    
    @IBOutlet weak var collectionView: UICollectionView! { didSet {
        let layout = SwipingCarouselFlowLayout()
        layout.activeDistance = 50 // your desired value. Remember 200 is the default.
        collectionView.setCollectionViewLayout(layout, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("----in view did load----")
        //tabBarController?.setupSwipeGestureRecognizers(allowCyclingThoughTabs: true)

        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
//        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshAppData(_:)), for: .valueChanged)
//        setupView()
//        profileImage.layer.borderWidth = 1
//        profileImage.layer.masksToBounds = false
//        profileImage.layer.borderColor = UIColor.black.cgColor
//        profileImage.layer.cornerRadius = profileImage.frame.height/2
//        profileImage.clipsToBounds = true
        imagePicker.delegate = self
        createGradientLayer()
        //appsTableView.layer.backgroundColor = UIColor.clear.cgColor
        //appsTableView.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.view.backgroundColor = .clear
        
        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "/6499/example/banner"
        bannerView.rootViewController = self
        bannerView.load(DFPRequest())
        
        //collectionView.setCollectionViewLayout(SwipingCarouselFlowLayout(), animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        profiles = []
        let dict1 = ["accounts": "[{'accountId': '136', 'displayName': 'Instagram', 'cognitoId': 'us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85', 'platform': 'Instagram', 'url': 'https://www.instagram.com/chris_deck', 'username': 'chris_deck'}, {'accountId': '145', 'displayName': 'Snapchat', 'cognitoId': 'us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85', 'platform': 'Snapchat', 'url': 'https://www.snapchat.com/add/chrisdeck', 'username': 'chrisdeck'}]", "name": "Going out", "qrCodeString": "qrCode!?", "info":"Snap & Insta"] as NSDictionary
        let profile = Profile(dictionary: dict1, imageIn: UIImage(named: "AddMeLogo-2.png")!)
        profiles.append(profile)
        var dict2 = ["accounts": "[{'accountId': '136', 'displayName': 'Instagram', 'cognitoId': 'us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85', 'platform': 'Instagram', 'url': 'https://www.instagram.com/chris_deck', 'username': 'chris_deck'}, {'accountId': '145', 'displayName': 'Snapchat', 'cognitoId': 'us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85', 'platform': 'Snapchat', 'url': 'https://www.snapchat.com/add/chrisdeck', 'username': 'chrisdeck'}]", "name": "Going out", "qrCodeString": "qrCode!?", "info":"(Snapchat, Insta)"] as NSDictionary
        let profile2 = Profile(dictionary: dict2, imageIn: UIImage(named: "AddMeLogo-2.png")!)
        profiles.append(profile2)
        let dict3 = ["accounts": "[{'accountId': '136', 'displayName': 'Instagram', 'cognitoId': 'us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85', 'platform': 'Instagram', 'url': 'https://www.instagram.com/chris_deck', 'username': 'chris_deck'}, {'accountId': '145', 'displayName': 'Snapchat', 'cognitoId': 'us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85', 'platform': 'Snapchat', 'url': 'https://www.snapchat.com/add/chrisdeck', 'username': 'chrisdeck'}]", "name": "Going out", "qrCodeString": "qrCode!?", "info":"Snap & Insta"] as NSDictionary
        let profile3 = Profile(dictionary: dict3, imageIn: UIImage(named: "AddMeLogo-2.png")!)
        profiles.append(profile3)
        var dict4 = ["accounts": "[{'accountId': '136', 'displayName': 'Instagram', 'cognitoId': 'us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85', 'platform': 'Instagram', 'url': 'https://www.instagram.com/chris_deck', 'username': 'chris_deck'}, {'accountId': '145', 'displayName': 'Snapchat', 'cognitoId': 'us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85', 'platform': 'Snapchat', 'url': 'https://www.snapchat.com/add/chrisdeck', 'username': 'chrisdeck'}]", "name": "Going out", "qrCodeString": "qrCode!?", "info":"(Snapchat, Insta)"] as NSDictionary
        let profile4 = Profile(dictionary: dict4, imageIn: UIImage(named: "AddMeLogo-2.png")!)
        profiles.append(profile4)
        print("Profiles!... \(profiles)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("----in view will appear----")
        self.tabBarController?.tabBar.isHidden = false
        presentAuthUIViewController()
        collectionView.reloadData()
       // appsTableView.reloadData()
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
                            //self.fetchAppData()
                            if AWSFacebookSignInProvider.sharedInstance().isLoggedIn {
                                print("facebook sign in confirmed")
                                self.navigationItem.leftBarButtonItem = nil
                                let params: String = "name,email,picture"
                                self.getFBUserInfo(params: params, dataset: self.datasetManager.dataset)
                            } else {
                                self.profileImage.image = UIImage(named: "launch_logo")
                                //self.navigationItem.leftBarButtonItem = self.uploadImageButton
                                //query the db for an image
                            }
                        }
                        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
                        self.profileImage.clipsToBounds = true;
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
//
//    func loadApps(){
//        print("loadApps()")
//        loadAppsFromDB()
//    }
//
    ////////////////////////////// BEGINNING OF JSON ///////////////////////////////////
    
    // TomMiller 2018/06/27 - Added struct to interact with JSON
    struct JsonApp: Decodable {
        //["{\"accounts\":[{\"cognitoId\":\"us-east-1:bafa67f1-8631-4c47-966d-f9f069b2107c\",\"displayName\":\"tomTweets\",\"platform\":\"Twitter\",\"url\":\"http://www.twitter.com/TomsTwitter\"}]}", ""]
        let accounts: [[String: String]]
    }
    
    var JsonApps = [JsonApp]()
    ////////////////////////////// END OF JSON ///////////////////////////////////
    
//    // Tom 2018/04/18
//    func loadAppsFromDB() {
//        print("RIGHT HERE")
//        apps = []
//        var returnList: [Apps] = []
//        let idString = self.credentialsManager.identityID!
//        print(idString)
//        let sema = DispatchSemaphore(value: 0);
//        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts/")!)
//        print(request)
//        request.httpMethod = "GET"
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
//
//        let task = URLSession.shared.dataTask(with: request, completionHandler: {
//        data, response, error in
//        if error != nil {
//            print("error=\(error)")
//            sema.signal()
//            return
//        } else {
//            print("---no error----")
//        }
//            //////////////////////// New stuff from Tom
//            do {
//                print(data)
//                print("decoding")
//                let decoder = JSONDecoder()
//                print("getting data")
//                let JSONdata = try decoder.decode(JsonApp.self, from: data!)
//                print(JSONdata)
//                if(JSONdata.accounts.count == 0){
//                    print("no accounts")
//                    returnList = []
//                    sema.signal()
//                } else {
//                    //=======
//                    for index in 0...JSONdata.accounts.count - 1 {
//                       let listOfAccountInfo = JSONdata.accounts[index]
//                        let displayName = listOfAccountInfo["displayName"]!
//                        let platform = listOfAccountInfo["platform"]!
//                        let url = listOfAccountInfo["url"]!
//                        let username = listOfAccountInfo["username"]!
//                        var appIdString = listOfAccountInfo["accountId"]!
//                      //  var isSwitchOn = listOfAccountInfo["isSwitchOn"]!
//    //                    if(appIdString.prefix(2) == "0x"){
//    //                        appIdString.removeFirst(2)
//    //                    }
//                        print(appIdString)
//                        let appId = Int(appIdString)!//, radix: 16)!
//                        print(displayName)
//                        print(platform)
//                        print(url)
//                        print(appId)
//                        //print(username)
//                        let app = Apps()
//                        app?._appId = "\(appId)"
//                        app?._displayName = displayName
//                        app?._platform = platform
//                        app?._uRL = url
//                        app?._username = username
//                        app?._isSwitchOn = "True"
//                        print(app)
//                        returnList.append(app!)
//                    }
//                }
//                    apps = returnList
//                    sema.signal();
//                    //=======
//                } catch let err {
//                    print("Err", err)
//                    apps = returnList
//                    sema.signal(); // none found TODO: do something better than this shit.
//                }
//                print("Done")
//        })
//        task.resume()
//        sema.wait(timeout: DispatchTime.distantFuture)
//        apps = returnList
//        cellSwitches = []
//        //self.appsTableView.reloadData()
//    }
    
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
    
    // Goes through the list of table cells that contain the switches for which apps
    // to use in the QR Code being made. It checks their label and UISwitch.
    // If the switch is "On" then it will be included in the QR codes creation.
    @IBAction func createQRCode(_ sender: Any) {
       // loadApps()
        var jsonStringAsArray = "{\n"
        print("createQRCode()")
        if(cellSwitches.count > 0){
            for index in 0...cellSwitches.count - 1{
                let isSelectedForQRCode = cellSwitches[index].appSwitch.isOn
                let appID = cellSwitches[index].id
                print(appID)
                print(isSelectedForQRCode)
                if (isSelectedForQRCode){
                    let app = apps[index]
                    jsonStringAsArray += "\"\(app._displayName!)\": \"\(app._uRL!)\",\n"
                } else {
                    print("app not found to make QR code")
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
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        print("height for row at method")
//        if indexPath.section == selectedSectionIndex && isCellTapped {
//            print("returning 180")
//            return 180
//        }
//        print("returning 140")
//        return 140
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("did select row at index path")
//        self.tableView(tableView, cellForRowAt: indexPath).backgroundColor = UIColor.gray
//
//        // avoid paint the cell is the index is outside the bounds
//        if self.selectedSectionIndex != -1 {
//            tableView.cellForRow(at: NSIndexPath(row: self.selectedSectionIndex, section: 0) as IndexPath)?.backgroundColor = UIColor.white
//        }
//
//        if selectedSectionIndex != indexPath.section {
//            self.isCellTapped = true
//            self.selectedSectionIndex = indexPath.section
//        }
//        else {
//            // there is no cell selected anymore
//            self.isCellTapped = false
//            self.selectedSectionIndex = -1
//        }
//
//        tableView.beginUpdates()
//        tableView.endUpdates()
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return apps.count
//    }
//
//    // There is just one row in every section
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    // Set the spacing between sections
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return cellSpacingHeight
//    }
//
//    // Make the background color show through
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clear
//        return headerView
//    }
//
//
//
//    // This is where the table cells on the main page are modeled from.
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        // Create an object of the dynamic cell “PlainCell”
//        let cell:AppsTableViewCell = appsTableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! AppsTableViewCell
//        print("Adding to table view now: \(cell)")
//        if (!cellSwitches.contains(cell)) {
//            cellSwitches.append(cell)
//        }
//        cell.NameLabel.text = apps[indexPath.section]._displayName
//        switch apps[indexPath.section]._platform {
//        case "Facebook"?:
//            cell.appImage.image = UIImage(named: "fb-icon")
//        case "Twitter"?:
//            cell.appImage.image = UIImage(named: "twitter_icon")
//        case "Instagram"?:
//            cell.appImage.image = UIImage(named: "Instagram_icon")
//        case "Snapchat"?:
//            cell.appImage.image = UIImage(named: "snapchat_icon")
//        case "GooglePlus"?:
//            cell.appImage.image = UIImage(named: "google_plus_icon")
//        case "LinkedIn"?:
//            cell.appImage.image = UIImage(named: "linked_in_logo")
//        case "Xbox"?:
//            cell.appImage.image = UIImage(named: "xbox")
//        case "PSN"?:
//            cell.appImage.image = UIImage(named: "play-station")
//        case "Twitch"?:
//            cell.appImage.image = UIImage(named: "twitch")
//        case "Custom"?:
//            cell.appImage.image = UIImage(named: "custom")
//        default:
//            cell.appImage.image = UIImage(named: "AppIcon")
//        }
//        //cell.NameLabel.textColor = UIColor.white
//        //cell.layer.backgroundColor = UIColor.clear.cgColor
//        cell.url.text = apps[indexPath.section]._uRL!
//        cell.id = Int(apps[indexPath.section]._appId!)
//        //print(indexPath.row)
//        if(indexPath.section == apps.count-1){
//            print("-----------about to create code----------")
//            createQRCode(self)
//        }
//        return cell
//    }
//    @IBAction func refreshTableView(_ sender: Any) {
//        print("refreshTableView()")
//        appsTableView.reloadData()
//    }
    
    @objc private func refreshAppData(_ sender: Any) {
        print("refreshAppData()")
        fetchAppData()
    }
//
    private func fetchAppData() {
        print("fetchAppData()")
        //load profiles
        self.updateView()
        self.refreshControl.endRefreshing()
        self.activityIndicatorView.stopAnimating()
    }
    
//    private func setupView() {
//        print("setUpView()")
//        setupTableView()
//        setupActivityIndicatorView()
//    }
//
    private func updateView() {
        print("updateView()")
        let hasProfiles = profiles.count > 0
        print("has apps: \(hasProfiles)")
        collectionView.isHidden = false
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        if hasProfiles {
            collectionView.reloadData()
        } else {
        }
    }
//
//    // MARK: -
//    private func setupTableView() {
//        print("setuptableView()")
//        appsTableView.isHidden = false// true
//        activityIndicatorView.isHidden = false
//    }
//
//    private func setupActivityIndicatorView() {
//        activityIndicatorView.startAnimating()
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let toViewController = segue.destination as? QRCodeViewController {
            toViewController.qrCodeString = "test"
        }
        
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
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let gradientView = UIView(frame: self.view.bounds)
        gradient.frame = view.frame
        gradient.colors = [UIColor(red: 61/255, green: 218/255, blue: 215/255, alpha: 1).cgColor, UIColor(red: 42/255, green: 147/255, blue: 213/255, alpha: 1).cgColor, UIColor(red: 19/255, green: 85/255, blue: 137/255, alpha: 1).cgColor]
        gradient.locations = [0.0, 0.5, 1.0]
//        gradient.colors = [UIColor(red: 42/255, green: 147/255, blue: 213/255, alpha: 1).cgColor, UIColor(red: 19/255, green: 85/255, blue: 137/255, alpha: 1).cgColor]
//        gradient.locations = [0.0, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        self.view.sendSubview(toBack: gradientView)
    }
    
    func addBannerViewToView(_ bannerView: DFPBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 200, left: 120, bottom: 200, right: 120)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            print(profiles)
            print("--------------------")
            return profiles.count
        }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         print("HERE!!!_____-----____")
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
                    print(profiles[indexPath.row])
                    cell.populateWith(card: profiles[indexPath.row])
                    cell.delegate = self
                    return cell
    }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("selected card \(indexPath.row)")
            performSegue(withIdentifier: "presentApps", sender: nil)
        }
    
    func cellSwipedUp(_ cell: UICollectionViewCell) {
        print("swipedUp")
        performSegue(withIdentifier: "presentCode", sender: nil)
    }
    
    func cellSwipedDown(_ cell: UICollectionViewCell) {
        print("swiped down")
        let alert = CDAlertView(title: "Deleting Profile", message: "Are you sure you wish to delete this profile?", type: .warning)
        let doneAction = CDAlertViewAction(title: "Sure! 💪",
                                           font: UIFont.systemFont(ofSize: 17),
                                           textColor: UIColor(red: 27 / 255, green: 169 / 255, blue: 225 / 255, alpha: 1),
                                           backgroundColor: nil,
                                           handler: { action in print("deleting")})
        alert.add(action: doneAction)
        let nevermindAction = CDAlertViewAction(title: "Nevermind 😬")
        alert.add(action: nevermindAction)
        alert.show()
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
    
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

