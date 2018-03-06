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


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var appsTableView: UITableView!
    @IBOutlet weak var scanButton: UIBarButtonItem!
    var token: String!
    var sideMenuViewController = SideMenuViewController()
    var isMenuOpened:Bool = false
    var dataset: AWSCognitoDataset!
    var identityProvider:String!
    var credentialsProvider:AWSCognitoCredentialsProvider!
    
    @IBOutlet weak var addAppButton: CustomButton!
    var apps: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("----in view did load----")
        sideMenuViewController = storyboard!.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
        sideMenuViewController.view.frame = UIScreen.main.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("----in view will appear----")
        if(isMenuOpened == true){
            isMenuOpened = false
            sideMenuViewController.willMove(toParentViewController: nil)
            sideMenuViewController.view.removeFromSuperview()
            sideMenuViewController.removeFromParentViewController()
        }
        presentAuthUIViewController()
        appsTableView.reloadData()
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
    
    func presentAuthUIViewController() {
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
        // Initialize the Amazon Cognito credentials provider
        
        if AWSSignInManager.sharedInstance().isLoggedIn {
            self.navigationController?.popToRootViewController(animated: true)
            credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                    identityPoolId:"us-east-1_6iZujg5TH")
            
            let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            loadApps()
            
            if AWSFacebookSignInProvider.sharedInstance().isLoggedIn {
                print("facebook sign in confirmed")
                identityProvider = "facebook"
                dataset.setString(identityProvider, forKey: "identityProvider")
                let fbProvider = FacebookProvider.init()
                let fbCredentialsProvider = fbProvider.logins()
                let dict: NSDictionary = fbCredentialsProvider.value(forKey: "result") as! NSDictionary
                let token: String = dict.value(forKey: "graph.facebook.com") as! String
                print(token)
                let params: String = "name,email,picture"
                getFBUserInfo(params: params, dataset: dataset)
            }
            if AWSGoogleSignInProvider.sharedInstance().isLoggedIn {
                print("google sign in confirmed")
                identityProvider = "google"
                let google = AWSGoogleSignInProvider.init()
                let token = google.token()
                print(token.result)
                dataset.setString(identityProvider, forKey: "identityProvider")
            }
            if AWSCognitoUserPoolsSignInProvider.sharedInstance().isLoggedIn() {
                print("user pool sign in confirmed")
                identityProvider = "user pool"
                dataset.setString(identityProvider, forKey: "identityProvider")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadApps(){
        // Initialize the Cognito Sync client
        let syncClient = AWSCognito.default()
        dataset = syncClient.openOrCreateDataset("AddMeDataSet")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
        let appsDataString = dataset.string(forKey: "apps")
        print(appsDataString)
        if(appsDataString == nil || appsDataString == "") {
            print("no apps yet")
            apps = []
        } else {
            let appsData: [String] = (appsDataString?.components(separatedBy: ","))!
            apps = appsData
            print(apps)
        }
    }
    
    func getFBUserInfo(params: String, dataset: AWSCognitoDataset) {
        let request = GraphRequest(graphPath: "me", parameters: ["fields":params], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
                case .success(let value):
                    print(value.dictionaryValue ?? "-1")
                    let userID = value.dictionaryValue?["id"] as! String
                    dataset.setString(userID, forKey: "userID")
                    let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(userID)/picture?type=large")
                    if let data = NSData(contentsOf: facebookProfileUrl!) {
                       // self.profilePicture.image = UIImage(data: data as Data)
                        
                    }
                dataset.setString(value.dictionaryValue?["id"] as? String, forKey: "Facebook")
                    //self.nameLabel.text = value.dictionaryValue?["name"] as? String
            case .failed(let error):
                print(error)
            }
        }
    }
    
    @IBAction func menuClicked(_ sender: Any) {
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
    
    @IBAction func createQRCode(_ sender: Any) {
        var jsonStringAsArray = "{\n"
        
        for app in apps {
            switch app {
            case "Facebook":
                let username = dataset.string(forKey: app)
                jsonStringAsArray += "\"facebook\":\"http://facebook.com/\(username!)\",\n"
            case "Twitter":
                let username = dataset.string(forKey: app)
                jsonStringAsArray += "\"twitter\":\"http://www.twitter.com/\(username!)\",\n"
            case "Instagram":
                let username = dataset.string(forKey: app)
                jsonStringAsArray += "\"instagram\":\"http://instagram.com/\(username!)\",\n"
            case "Snapchat":
                let username = dataset.string(forKey: app)
                jsonStringAsArray += "\"snapchat\":\"http://www.snapchat.com/add/\(username!)\",\n"
            default:
                print("unknown app found: \(app)")
            }
        }
        jsonStringAsArray += "}"
        let result = jsonStringAsArray.replacingLastOccurrenceOfString(",",
                                                              with: "")
        print(result)
       dataset.setString(result, forKey: "jsonStringAsArray")
    }
    
    func tableView(_ ExpensesTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apps.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an object of the dynamic cell “PlainCell”
        let cell:AppsTableViewCell = appsTableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! AppsTableViewCell
        cell.NameLabel.text = apps[indexPath.row]
        return cell
    }
    @IBAction func refreshTableView(_ sender: Any) {
        appsTableView.reloadData()
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

