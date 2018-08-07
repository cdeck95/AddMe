//
//  HelpViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 3/15/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var issuePicker: UIPickerView!
    var pickerData: [String] = ["Cannot connect apps", "Cannot create code", "Code is wrong", "Cannot scan code", "Cannot delete apps"]
    @IBOutlet weak var issueDetails: UITextView!
    var generalIssue:String!
    
    override func viewDidLoad() {
        print("Loading Help Screen")
        super.viewDidLoad()
        //Connect data:
        self.issuePicker.delegate = self
        self.issuePicker.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        print("Send Email Function")
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            print("Can send")
            let text = issueDetails.text
            if (text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
               print("They didn't enter any details")
                let alert = UIAlertController(title: "Enter more details please.", message: "It's important that you let us know what went wrong, so we can fix it for you in the future.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
            }else{
                self.present(mailComposeViewController, animated: true, completion: nil)
            }
        } else {
            print("Can't send")
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        print("Configuring")
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        if (generalIssue == nil){
            // This is when they don't physically choose an issue. It assigns the first one, since that is what they see anyway.
            generalIssue = "Cannot connect apps"
        }
        mailComposerVC.setToRecipients(["support@tc2pro.com"])
        mailComposerVC.setSubject("AddMe - Issue - \(generalIssue!)")
        mailComposerVC.setMessageBody(issueDetails.text, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        print("Show Send Mail Error Alert")
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("Mail Compose Control")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        print("Number of Components")
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("Picker View count: \(pickerData.count)")
        return pickerData.count
    }
    
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("pickerView array \(pickerData[row])")
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        print("pickerView general issue:")
        generalIssue = pickerData[row] as String
        print(generalIssue)
    }
    
    //hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //hide keyboard when user hits return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
