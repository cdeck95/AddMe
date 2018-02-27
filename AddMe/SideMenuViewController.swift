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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
                DispatchQueue.main.async(execute: {
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
                })
            })
            //print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            //assert(false)
        }
    }

    
//    @IBAction func goHome(_ sender: Any) {
//        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! ViewController
//        self.navigationController!.popToViewController(VC1, animated: true)
//    }
    
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
