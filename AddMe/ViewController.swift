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
import GoogleSignIn
import FacebookCore


class ViewController: UIViewController {


    @IBOutlet weak var scanButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    var token: String!
    var sideMenuViewController = SideMenuViewController()
    var isMenuOpened:Bool = false
    var dataset: AWSCognitoDataset!
    
    
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
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                    identityPoolId:"us-east-1:99eed9b4-f0a9-4f6d-b34c-5f05a1a5fa6b")
            
            let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            // Initialize the Cognito Sync client
            let syncClient = AWSCognito.default()
            dataset = syncClient.openOrCreateDataset("AddMeDataSet")
            dataset.setString(token, forKey:"token")
            dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
                // Your handler code here
                return nil
                
            }
            
            if AWSFacebookSignInProvider.sharedInstance().isLoggedIn {
                print("facebook sign in confirmed")
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
            }
            if AWSCognitoUserPoolsSignInProvider.sharedInstance().isLoggedIn() {
                print("user pool sign in confirmed")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let jsonStringAsArray =
            "{\n" +
                "\"twitter\":\"http://www.twitter.com/cporchie\",\n" +
                "\"snapchat\":\"http://www.snapchat.com/add/cporchie\",\n" +
                "\"facebook\":\"http://facebook.com/cporchie\",\n" +
                "\"instagram\":\"http://instagram.com/chris_deck\"\n" +
        "}"
       dataset.setString(jsonStringAsArray, forKey: "jsonStringAsArray")
    }
    
    
}

