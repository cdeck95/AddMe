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
import GoogleMobileAds
import Sheeeeeeeeet

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var bannerView: DFPBannerView!
    var gradient: CAGradientLayer!
//    @IBOutlet weak var issuePicker: UIPickerView!
//    var pickerData: [String] = ["Cannot connect accounts", "Cannot create QR code", "QR Code is wrong", "Cannot scan/import QR code" , "Cannot edit/delete apps", "Other (Please Specify)"]
    @IBOutlet weak var issueDetails: UITextView!
    var generalIssue:String!
    
    @IBOutlet var helpIssueTableView: UITableView!
    
    override func viewDidLoad() {
        print("Loading Help Screen")
        super.viewDidLoad()
        tabBarController?.setupSwipeGestureRecognizers(allowCyclingThoughTabs: true)
        //Connect data:
//        self.issuePicker.delegate = self
//        self.issuePicker.dataSource = self
        // Do any additional setup after loading the view.
       // createGradientLayer()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.view.backgroundColor = .clear
        
        self.issueDetails.textColor = UIColor.black
        self.issueDetails.delegate = self
        self.issueDetails.layer.borderWidth = 1.0
        let version : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let build : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
        let systemVersion = UIDevice.current.systemVersion
        print("Version: \(version)")
        print("Build: \(build)")
        print("OS: \(systemVersion)")
        issueDetails.text = "\n\nOS: \(systemVersion) \nVersion: \(version!) \nBuild: \(build!)"
        
        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "/6499/example/banner"
        bannerView.rootViewController = self
        bannerView.load(DFPRequest())
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.helpIssueTableView.layer.backgroundColor = UIColor.clear.cgColor
        self.helpIssueTableView.layer.borderColor = UIColor.clear.cgColor
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
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        print("Number of Components")
//        return 1
//    }
    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        print("Picker View count: \(pickerData.count)")
//        return pickerData.count
//    }
//
//
//    // The data to return for the row and component (column) that's being passed in
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        print("pickerView array \(pickerData[row])")
//        return pickerData[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
//        print("pickerView general issue:")
//        generalIssue = pickerData[row] as String
//        print(generalIssue)
//    }
    
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
       // self.gradientLayer.layer.addSublayer(gradient)
      //  self.view.sendSubview(toBack: self.gradientLayer)//(gradient, at: 0)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        issueDetails.layer.borderColor = Color.coral.value.cgColor
        issueDetails.layer.borderWidth = 2.0
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        issueDetails.layer.borderColor = Color.marina.value.cgColor
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HelpTableViewCell = helpIssueTableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath) as! HelpTableViewCell
        cell.generalIssue.text = "Issue Category"
        generalIssue = "Issue category"
        cell.layer.backgroundColor = UIColor.white.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actionSheet = createStandardActionSheet(indexPath: indexPath)
        actionSheet.present(in: self, from: self.view)
    }
    
    func createStandardActionSheet(indexPath: IndexPath) -> ActionSheet {
        let title = ActionSheetTitle(title: "What are you having trouble with?")
        let item1 = ActionSheetItem(title: "App Crashing", value: "1", image: UIImage(named: "baseline_bug_report_black_18pt"))
        let item2 = ActionSheetItem(title: "QR code", value: "2", image: UIImage(named: "baseline_share_black_18pt"))
        let item3 = ActionSheetItem(title: "Camera", value: "3", image: UIImage(named: "baseline_camera_alt_black_18pt"))
        let item4 = ActionSheetItem(title: "Profiles", value: "4", image: UIImage(named: "baseline_account_circle_black_18pt"))
        let item5 = ActionSheetItem(title: "Accounts", value: "5", image: UIImage(named: "baseline_account_circle_black_18pt"))
        let item6 = ActionSheetItem(title: "Other (please specify)", value: "6", image: UIImage(named: "baseline_help_black_18pt"))
        let button = ActionSheetOkButton(title: "Cancel")
        return ActionSheet(items: [title, item1, item2, item3, item4, item5, item6, button]) { _, item in
            let value = item.title
            if(value == "Cancel"){
                //do nothing
            } else {
                let cell = self.helpIssueTableView.cellForRow(at: indexPath) as! HelpTableViewCell
                cell.generalIssue.text = value
                self.generalIssue = value
            }
            self.helpIssueTableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
