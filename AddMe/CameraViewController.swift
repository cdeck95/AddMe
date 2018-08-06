//
//  CameraViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 4/17/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate {
    
 
   // @IBOutlet weak var loadedImage: UIImageView!
    let imagePicker = UIImagePickerController()
    var detector: CIDetector?
    var dict: [String: String]!
    var keys: Dictionary<String, String>.Keys!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        //takePhoto(sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let alertController = UIAlertController(title: "Upload another?", message: "Would you like to add another friend?", preferredStyle: .alert)
//
//
//        //the confirm action taking the inputs
//        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
//             self.takePhoto(sender: self)
//        }
//
//        //the cancel action doing nothing
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
//
//        //adding the action to dialogbox
//        alertController.addAction(confirmAction)
//        alertController.addAction(cancelAction)
//
//        //finally presenting the dialog box
//        self.present(alertController, animated: true, completion: nil)
       
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let qrcodeImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
          //  loadedImage.image = qrcodeImg
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage=CIImage(image:qrcodeImg)!
            var qrCodeLink=""
            
            let features=detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
            }
            
            if qrCodeLink=="" {
                print("nothing")
            }else{
                print("message: \(qrCodeLink)")
                // convert NSData to 'AnyObject'
                let stringData = qrCodeLink.data(using: String.Encoding.utf8)
                
                do {
                    guard let result = (try JSONSerialization.jsonObject(with: stringData!, options: [])
                        as? [String: String]) else {
                            print("error trying to convert data to JSON")
                            return
                    }
                    dict = result
                    print("dict:  \(dict)")
                    openPlatforms()
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func openPlatforms(){
        keys = dict.keys
        print("keys")
        if(dict.count > 0){
            
            let currentKey = keys.first!
            print("current key: \(currentKey)")
            let currentURL = dict[currentKey]!
            print("current url: \(currentURL)")
            let url = URL(string: currentURL)
            self.tabBarController?.hidesBottomBarWhenPushed = true
            var platform = ""
            if (currentURL.contains("twitter.com")){
                platform = "Twitter"
            } else if (currentURL.contains("twitch.tv")){
                platform = "Twitch"
            } else if (currentURL.contains("instagram.com")){
                platform = "Instagram"
            } else if (currentURL.contains("linkedin.com")){
                platform = "LinkedIn"
            } else if (currentURL.contains("snapchat.com")){
                platform = "Snapchat"
            } else {
                platform = "other"
            }
            
            
            switch platform {
            case "Twitter":
                openNative(url: url!, currentKey: currentKey)
            case "Twitch":
                openNative(url: url!, currentKey: currentKey)
            case "Instagram":
                openNative(url: url!, currentKey: currentKey)
            case "LinkedIn":
                openNative(url: url!, currentKey: currentKey)
            case "Snapchat":
                openNative(url: url!, currentKey: currentKey)
            default:
                let svc = SFSafariViewController(url: URL(string: currentURL)!)
                svc.delegate = self
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.pushViewController(svc, animated: true)
            }
            dict.removeValue(forKey: currentKey)
        }
    }
    
    func openNative(url: URL, currentKey: String){
        
        if(UIApplication.shared.canOpenURL(url)){
            print("opening natively...")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("opening in safari...")
            let svc = SFSafariViewController(url: url)
            svc.delegate = self
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.pushViewController(svc, animated: true)
        }
        dict.removeValue(forKey: currentKey)
        if keys.count == 0 {
            print("popping...")
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.selectedIndex = 1
            //self.navigationController?.popViewController(animated: true)//popToRootViewController(animated: true)
        }
        openPlatforms()
    }
    
    
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
        if keys.count == 0 {
            print("popping...")
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.selectedIndex = 1
            //self.navigationController?.popToRootViewController(animated: true)
        }
        else {
            openPlatforms()
        }
        dismiss(animated: true)
    }
    
}

