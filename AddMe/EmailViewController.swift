//
//  EmailViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 3/14/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import MessageUI
import UIKit

class EmailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        sendEmail()
    }
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["support@tc2pro.com"])
        composeVC.setSubject("AddMe - Issue - [insert general issue statement]")
        composeVC.setMessageBody("Please insert general issue statement above - then describe the issue in  detail inthe body of the email.", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    private func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
        controller.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


