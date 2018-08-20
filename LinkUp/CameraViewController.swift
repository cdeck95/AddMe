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
import GoogleMobileAds

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate, GADInterstitialDelegate {
    
 
    var bannerView: DFPBannerView!
    var interstitial: DFPInterstitial!
    let imagePicker = UIImagePickerController()
    var detector: CIDetector?
    var dict: [String: String]!
    var keys: Dictionary<String, String>.Keys!
    var nativeApps = [Apps]()
    var safariApps = [Apps]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "/6499/example/banner"
        bannerView.rootViewController = self
        bannerView.load(DFPRequest())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imagePicker.delegate = self
        interstitial = createAndLoadInterstitial()
//        tabBarController?.setupSwipeGestureRecognizers(allowCyclingThoughTabs: true)
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
                     openPlatforms()
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
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func openPlatforms(){
        if(safariApps.count > 0){
            let url = URL(string: (safariApps.first?._uRL)!)
            let svc = SFSafariViewController(url: url!)
            svc.delegate = self
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.pushViewController(svc, animated: true)
            safariApps.removeFirst()
        } else if(nativeApps.count > 0){
            let url = URL(string: (nativeApps.first?._uRL)!)
            openNative(url: url!)
        }
    }
    
    func openNative(url: URL){
        print("in open native...")
        print(url)
//        if(UIApplication.shared.canOpenURL(url)){
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            //dict.removeValue(forKey: currentKey)
//            if nativeApps.count == 0 {
//                print("popping...")
//                self.navigationController?.setNavigationBarHidden(false, animated: true)
//                self.navigationController?.popToRootViewController(animated: true)
//            } else {
//                nativeApps.removeFirst()
//                let mainQueue = DispatchQueue.main
//                let deadline = DispatchTime.now() + .seconds(1)
//                mainQueue.asyncAfter(deadline: deadline) {
//                    self.openPlatforms()
//                }
//
//            }
//        } else {
            print("opening in safari...")
            let svc = SFSafariViewController(url: url)
            svc.delegate = self
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.pushViewController(svc, animated: true)
            nativeApps.removeFirst()
      //  }
        
    }
    
    func convertToArray(){
        keys = dict.keys
        //print("keys")
        
        for (displayName, url) in dict {
            print("display name: \(displayName)")
            print("url: \(url)")
            let app = Apps()
            app?._displayName = displayName
            app?._uRL = url
            self.tabBarController?.hidesBottomBarWhenPushed = true
            var platform = ""
            if (url.contains("twitter.com")){
                platform = "Twitter"
            } else if (url.contains("twitch.tv")){
                platform = "Twitch"
            } else if (url.contains("instagram.com")){
                platform = "Instagram"
            } else if (url.contains("linkedin.com")){
                platform = "LinkedIn"
            } else if (url.contains("snapchat.com")){
                platform = "Snapchat"
            } else {
                platform = "other"
            }
            
            
            switch platform {
            case "Twitter":
                app?._platform = platform
                nativeApps.append(app!)
            case "Twitch":
                app?._platform = platform
                nativeApps.append(app!)
            case "Instagram":
                app?._platform = platform
                nativeApps.append(app!)
            case "LinkedIn":
                app?._platform = platform
                nativeApps.append(app!)
            case "Snapchat":
                app?._platform = platform
                nativeApps.append(app!)
            default:
                app?._platform = platform
                safariApps.append(app!)
            }
        }
        print(safariApps)
        print(nativeApps)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        print("did finish")
        controller.dismiss(animated: true, completion: nil)
        if nativeApps.count == 0  && safariApps.count == 0{
            print("popping...")
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        else {
            openPlatforms()
        }
      //  dismiss(animated: true)
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
    
    func createAndLoadInterstitial() -> DFPInterstitial {
        var interstitial = DFPInterstitial(adUnitID: "/6499/example/interstitial")
        interstitial.delegate = self
        interstitial.load(DFPRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: DFPInterstitial) {
        //interstitial = createAndLoadInterstitial()
        dismiss(animated: true, completion: nil)
    }
    
}

