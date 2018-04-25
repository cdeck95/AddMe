//
//  SideMenuViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/26/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSAuthUI
import AWSMobileClient
import AWSFacebookSignIn
import AWSGoogleSignIn

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var LogoutButton: UIButton!
    @IBOutlet weak var SettingsButton: UIButton!
    @IBOutlet weak var HomeButton: UIButton!
    var credentialsManager = CredentialsManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        credentialsManager.createCredentialsProvider()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goHome(_ sender: Any) {
        print("going home")
        if(self.navigationController == nil){
            
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        let config = AWSAuthUIConfiguration()
        config.enableUserPoolsUI = true
        config.addSignInButtonView(class: AWSFacebookSignInButton.self)
        config.addSignInButtonView(class: AWSGoogleSignInButton.self)
        config.logoImage = UIImage(named: "launch_logo")
        config.backgroundColor = UIColor.white
        config.font = UIFont (name: "Helvetica Neue", size: 14)
        config.canCancel = true
        
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            if(AWSFacebookSignInProvider.sharedInstance().isLoggedIn){
                AWSFacebookSignInProvider.sharedInstance().logout()
                AWSAuthUIViewController
                    .presentViewController(with: self.navigationController!,
                                           configuration: config,
                                           completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                            if error != nil {
                                                print("Error occurred: \(String(describing: error))")
                                            } else {
                                                
                                            }
                    })
            } else {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
                DispatchQueue.main.async(execute: {
                    AWSAuthUIViewController
                        .presentViewController(with: self.navigationController!,
                                               configuration: config,
                                               completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                                if error != nil {
                                                    print("Error occurred: \(String(describing: error))")
                                                } else {
            
                                                }
                        })
                    self.credentialsManager.credentialsProvider.clearKeychain()
                    self.credentialsManager.credentialsProvider.clearCredentials()
                    
                    print(result)
                })
            })
            //print("Logout Successful: \(signInProvider.getDisplayName)");
        }
        } else {
            
        }
    }

    

    
//    @IBAction func openSettings(_ sender: Any) {
//        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
//        self.navigationController!.present(VC1, animated: true, completion: nil)
//    }
//    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
