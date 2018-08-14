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
   // let svc: SFSafariViewController! = nil
    var detector: CIDetector?
    var dict: [String: String]!
    var keys: Dictionary<String, String>.Keys!
    var nativeApps = [Apps]()
    var safariApps = [Apps]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imagePicker.delegate = self
        //svc.delegate = self
        tabBarController?.setupSwipeGestureRecognizers(allowCyclingThoughTabs: true)
        //takePhoto(sender: self)
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
                    convertToArray()
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        else{
            print("Something went wrong")
        }
        print("about to dismiss image picker")
        self.imagePicker.dismiss(animated: true, completion: nil)
        print("image picker dismissed")
    }
    
    func openPlatforms(){
        print(safariApps)
        let url = URL(string: (safariApps.first?._uRL!)!)
        openNative(url: url!, flag: false)
    }
    
//    func openPlatformsNative(){
//        print(nativeApps)
//        for app in nativeApps{
//            print(app)
//            let url = URL(string: app._uRL!)
//            let success = openNative(url: url!, flag: true)
//            while(!success){}
//            print("returned true")
//        }
//        print("popping...")
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.tabBarController?.selectedIndex = 1
//    }
    
    func openNative(url: URL, flag: Bool){
        if(!flag){
            print("opening in safari & flag was false...")
            print(url)
            //openWithSafari(url: url)
            let svc = SFSafariViewController(url: url)
            svc.delegate = self
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.pushViewController(svc, animated: true)
            //self.navigationController?.present(svc, animated: true, completion: nil)
            //present(svc, animated: true, completion: nil)
            safariApps.removeFirst()
        } else{
            print("opening natively...")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
//
//    func openWithSafari(url: URL){
//
//    }
//
    
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
//        self.navigationController?.popViewController(animated: true)
        controller.dismiss(animated: true, completion: nil)
//        print(safariApps)
//        if safariApps.count == 0 {
//            print("end of array")
//            //openPlatformsNative()
//        }
//        else {
//            openPlatforms()
//        }
    }

    func convertToArray(){
        keys = dict.keys
        //print("keys")
        let app = Apps()
        if(dict.count > 0){
            
            let currentKey = keys.first!
            //print("current key: \(currentKey)")
            app?._displayName = currentKey
            let currentURL = dict[currentKey]!
           // print("current url: \(currentURL)")
            let url = URL(string: currentURL)
            app?._uRL = currentURL
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
                app?._platform = platform
                nativeApps.append(app!)
                dict.removeValue(forKey: currentKey)
                convertToArray()
            case "Twitch":
                app?._platform = platform
                nativeApps.append(app!)
                dict.removeValue(forKey: currentKey)
                convertToArray()
            case "Instagram":
                app?._platform = platform
                nativeApps.append(app!)
                dict.removeValue(forKey: currentKey)
                convertToArray()
            case "LinkedIn":
                app?._platform = platform
                nativeApps.append(app!)
                dict.removeValue(forKey: currentKey)
                convertToArray()
            case "Snapchat":
                app?._platform = platform
                nativeApps.append(app!)
                dict.removeValue(forKey: currentKey)
                convertToArray()
            default:
                app?._platform = platform
                safariApps.append(app!)
                dict.removeValue(forKey: currentKey)
                convertToArray()
            }
        }
        else {
            openPlatforms()
        }
    }
    
}

