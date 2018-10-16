//
//  QRCodeViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/25/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import Foundation
import AWSCognito

class QRCodeViewController: UIViewController, HalfModalPresentable {

    @IBOutlet weak var QRCode: UIImageView!
    var dataset: AWSCognitoDataset!
    var credentialsManager = CredentialsManager.sharedInstance
    var datasetManager = Dataset.sharedInstance
    var qrCode:UIImage!
    var profileId:Int!
    var shouldShare:Bool = false
    
    @IBOutlet var shareButton: UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createQRCode(self)
        print("qr code string: \(profileId)")
        if(shouldShare){
            shareButtonClicked(sender: shareButton)
        }
//        tabBarController?.setupSwipeGestureRecognizers(allowCyclingThoughTabs: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func scan(_ sender: Any) {
        let scannerVC = ScannerViewController()
        self.navigationController?.pushViewController(scannerVC, animated: true)
    }
    
    @IBAction func createQRCode(_ sender: Any) {
        //profiles = []
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        if let url = URL(string: "https://api.tc2pro.com/users/\(idString)/profiles/\(profileId!)/qr") {
            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            QRCode.image = UIImage(data: data!)
        } else {
            print("could not open url, it was nil")
        }
    }

    
    @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
        print("share button clicked")
       
        let objectsToShare = [QRCode.image] as [AnyObject]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact]
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if (error == nil) {
                if (activityType == UIActivity.ActivityType.saveToCameraRoll) {
                    //TODO: Make FCAlertView
                    //CDAlertView(title: "Success!", message: "Your QR code is now saved to your camera roll!", type: .success).show()
                    return
                } else if (activityType == UIActivity.ActivityType.copyToPasteboard) {
                    //TODO: FCAlertView
                    //CDAlertView(title: "Success!", message: "Your QR code is now copied to your Pasteboard!", type: .success).show()
                    return
                } else if (activityType == UIActivity.ActivityType.message) {
                    self.dismiss(animated: false, completion: nil)
                }
            } else {
                //TODO: FCAlertView
                //CDAlertView(title: "Uh Oh!", message: "Something went wrong. Please try again. If this keeps happening, contact our support team and we will be happy to assist.", type: .error).show()
                print(error)
                return
            }
            
        }
        self.present(activityVC, animated: true, completion: nil)
    }

}
