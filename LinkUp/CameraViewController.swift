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
//import TransitionButton
import FCAlertView

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate, GADInterstitialDelegate, UIPopoverControllerDelegate, FCAlertViewDelegate {
    
    var gradient:CAGradientLayer!
    var credentialsManager = CredentialsManager.sharedInstance
    var bannerView: DFPBannerView!
    var interstitial: DFPInterstitial!
    let imagePicker = UIImagePickerController()
    var detector: CIDetector?
    var dict: [String: String]!
    var keys: Dictionary<String, String>.Keys!
    var nativeApps = [PagedAccounts.Accounts]()
    var safariApps = [PagedAccounts.Accounts]()
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    @IBOutlet var importButton: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.credentialsManager.createCredentialsProvider()
        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "/6499/example/banner"
        bannerView.rootViewController = self
        bannerView.load(DFPRequest())
        createGradientLayer()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imagePicker.delegate = self
        interstitial = createAndLoadInterstitial()
        safariApps = []
        nativeApps = []
    //    self.navigationController?.setNavigationBarHidden(true, animated: true)
//        tabBarController?.setupSwipeGestureRecognizers(allowCyclingThoughTabs: true)
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        importButton.startAnimation()
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        //sleep(1)
        
        present(imagePicker, animated: true, completion: nil)
        importButton.stopAnimation()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let qrcodeImg = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
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
                    getProfile(dict: dict)
                    // convertToArray()
                     //openPlatforms()
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
            let url = URL(string: (safariApps.first?.url)!)
            let svc = SFSafariViewController(url: url!)
            svc.delegate = self
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.pushViewController(svc, animated: true)
            safariApps.removeFirst()
        } else if(nativeApps.count > 0){
            let url = URL(string: (nativeApps.first?.url)!)
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
            var app:PagedAccounts.Accounts!
            app.displayName = displayName
            app.url = url
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
                app.platform = platform
                nativeApps.append(app!)
            case "Twitch":
                app.platform = platform
                nativeApps.append(app!)
            case "Instagram":
                app.platform = platform
                nativeApps.append(app!)
            case "LinkedIn":
                app.platform = platform
                nativeApps.append(app!)
            case "Snapchat":
                app.platform = platform
                nativeApps.append(app!)
            default:
                app.platform = platform
                safariApps.append(app!)
            }
        }
        print(safariApps)
        print(nativeApps)
        
        var allApps:[PagedAccounts.Accounts] = []
        for app in safariApps {
            allApps.append(app)
        }
        for app in nativeApps {
            allApps.append(app)
        }
        
        //present popove
       
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
    
    func getProfile(dict: [String:String]){
        //profiles = []
        let profileId = dict.first?.value
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        if let url = URL(string: "https://api.tc2pro.com/users/\(idString)/scans/\(profileId!)") {
            var request = URLRequest(url: url)
            print(request)
            request.httpMethod = "POST"
            request.cachePolicy = .reloadIgnoringCacheData
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
            let task = URLSession.shared.dataTask(with: request, completionHandler: {
                data, response, error in
                if error != nil {
                    print("error=\(error)")
                    sema.signal()
                    return
                } else {
                    print("---no error----")
                }
                //////////////////////// New stuff from Tom
                do {
                    let decoder = JSONDecoder()
                    let parser = APICodeParser(message: response.debugDescription)
                    print(data)
                    print(response)
                    let profile = try decoder.decode(SingleProfile.self, from: data!)
                    OperationQueue.main.addOperation {
                        print("in completion")
                        let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "SingleProfileViewController") as! SingleProfileViewController
                        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                        modalVC.allAccounts = profile.profile.accounts
                        modalVC.profile = profile.profile
                        modalVC.modalTransitionStyle = .crossDissolve
                        modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
                       // self.navigationController?.setNavigationBarHidden(true, animated: true)
                        //self.navigationController?.present(modalVC, animated: true, completion: nil)
                        self.navigationController?.pushViewController(modalVC, animated: true)
                    }
                    sema.signal();
                    //=======
                } catch let err {
                    print("Err", err)
                    sema.signal(); // none found TODO: do something better than this shit.
                }
                print("Done")
                /////////////////////////
            })
            task.resume()
            sema.wait(timeout: DispatchTime.distantFuture)
            
            //send to another view controller to view profile
        } else {
            print("could not open url, it was nil")
        }
    }
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let gradientView = UIView(frame: self.view.bounds)
        gradient.frame = view.frame
        gradient.colors = [Color.glass.value.cgColor, Color.glass.value.cgColor]
        gradient.locations = [0.0, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        self.view.sendSubviewToBack(gradientView)
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
