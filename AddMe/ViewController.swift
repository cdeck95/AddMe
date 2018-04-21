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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var appsTableView: UITableView!
    @IBOutlet weak var scanButton: UIBarButtonItem!
    var token: String!
    var sideMenuViewController = SideMenuViewController()
    var isMenuOpened:Bool = false
    var identityProvider:String!
    var credentialsManager = CredentialsManager.sharedInstance
    var datasetManager = Dataset.sharedInstance
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
   
    @IBOutlet weak var addAppButton: UIBarButtonItem!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("----in view did load----")
        sideMenuViewController = storyboard!.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
        sideMenuViewController.view.frame = UIScreen.main.bounds
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("----in view will appear----")
        if(isMenuOpened == true){
            isMenuOpened = false
            sideMenuViewController.willMove(toParentViewController: nil)
            sideMenuViewController.view.removeFromSuperview()
            sideMenuViewController.removeFromParentViewController()
        }
        cellSwitches = []
        self.tabBarController?.tabBar.isHidden = false
        presentAuthUIViewController()
        appsTableView.reloadData()
        createQRCode(self)
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
                                
                                let params: String = "name,email,picture"
                                self.getFBUserInfo(params: params, dataset: self.datasetManager.dataset)
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
    
    // Tom 2018/04/18
    func loadAppsFromDB() {
        var returnList: [Apps] = []
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
            var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/getUserInfo.php")!)
            request.httpMethod = "POST"
            let postString = "a=\(idString)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                sema.signal()
                return
            } else {
                print("---no error----")
            }
                
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            let lines = responseOne!.components(separatedBy: "\n")
            print(lines)
                
                // Goes through and picks out the platforms.
                if (lines.count > 3){
                    for index in stride(from:0, to: lines.count-1, by: 4) {
                        print(index)
                        let app = Apps()
                        app?._userId = lines[index]
                        app?._displayName = lines[index+1]
                        app?._platform = lines[index+2]
                        app?._uRL = lines[index+3]
                        print(app)
                        returnList.append(app!)
                    }
                    apps = returnList
                    sema.signal();
                }
                else {
                    apps = returnList
                    sema.signal()
                }
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
    
    @IBAction func menuClicked(_ sender: Any) {
        print("menuClicked()")
        if(isMenuOpened){
            isMenuOpened = false
            sideMenuViewController.willMove(toParentViewController: nil)
            sideMenuViewController.view.removeFromSuperview()
            sideMenuViewController.removeFromParentViewController()
        }
        else{
            isMenuOpened = true
            self.addChildViewController(sideMenuViewController)
            self.view.addSubview(sideMenuViewController.view)
            sideMenuViewController.didMove(toParentViewController: self)
        }
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
    
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
        cell.id = Int(apps[indexPath.row]._userId!)
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

