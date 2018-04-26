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
    
 
    @IBOutlet weak var loadedImage: UIImageView!
    let imagePicker = UIImagePickerController()
    var detector: CIDetector?
    var dict: [String: String]!
    var keys: Dictionary<String, String>.Keys!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
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
            loadedImage.image = qrcodeImg
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
        if(dict.count > 0){
            
            let currentKey = keys.first!
            print("current key: \(currentKey)")
            let currentURL = dict[currentKey]!
            print("current url: \(currentURL)")
            self.tabBarController?.hidesBottomBarWhenPushed = true
            let svc = SFSafariViewController(url: URL(string: currentURL)!)
            svc.delegate = self
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.pushViewController(svc, animated: true)
            dict.removeValue(forKey: currentKey)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
        if keys.count == 0 {
            print("popping...")
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
        else {
            openPlatforms()
        }
        dismiss(animated: true)
    }
    
}

