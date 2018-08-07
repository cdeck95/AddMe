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

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    @IBOutlet var gradientLayer: UIView!
    var gradient: CAGradientLayer!
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
        createGradientLayer()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.view.backgroundColor = .clear
        
        self.issueDetails.textColor = UIColor.white
        self.issueDetails.delegate = self
        self.issueDetails.layer.borderWidth = 1.0
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
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let view = UIView(frame: self.view.bounds)
        gradient.frame = view.frame
        gradient.colors = [UIColor(red: 0.47, green: 0.79, blue: 0.83, alpha: 1).cgColor, UIColor(red: 0.34, green: 0.74, blue: 0.56, alpha: 1).cgColor]
        gradient.locations = [0.0, 1.0]
        //        gradient.colors = [UIColor(red: 0.47, green: 0.79, blue: 0.83, alpha: 1).cgColor, UIColor(red: 0.34, green: 0.74, blue: 0.56, alpha: 1).cgColor, UIColor(red: 1/255, green: 82/255, blue: 73/255, alpha:1).cgColor]
        //        gradient.locations = [0.0, 0.5, 1.0]
        self.view.backgroundColor = UIColor.clear
        self.gradientLayer.layer.addSublayer(gradient)
        self.view.sendSubview(toBack: self.gradientLayer)//(gradient, at: 0)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        issueDetails.layer.borderColor = UIColor(red: 0.47, green: 0.79, blue: 0.83, alpha: 1).cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        issueDetails.layer.borderColor = UIColor(red: 1/255, green: 82/255, blue: 73/255, alpha:1).cgColor
    }

}
