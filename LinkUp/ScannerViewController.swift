//
//  ScannerViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/23/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices
import GoogleMobileAds

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, SFSafariViewControllerDelegate, GADInterstitialDelegate {
    
   // var profiles: [PagedProfile.Profile]!
    var credentialsManager = CredentialsManager.sharedInstance
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var dict: [String: String]!
    var twitter = 0
    var facebook = 0
    var keys: Dictionary<String, String>.Keys!
    var nativeApps = [PagedAccounts.Accounts]()
    var safariApps = [PagedAccounts.Accounts]()
    var interstitial: DFPInterstitial!
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        //self.navigationController?.navigationBar.isHidden  = true
        self.credentialsManager.createCredentialsProvider()
        //tabBarController?.setupSwipeGestureRecognizers(allowCyclingThoughTabs: true)
//
//        interstitial = DFPInterstitial(adUnitID: "/6499/example/interstitial")
//        interstitial.delegate = self
//        let request = DFPRequest()
//        interstitial.load(request)
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        interstitial = createAndLoadInterstitial()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
       // let group = DispatchGroup()
       // group.enter()
      
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
           // DispatchQueue.main.async {
                self.found(code: stringValue)
           //     group.leave()
           // }
        }
        //group.notify(queue: .main) {
            self.dismiss(animated: true){
            
        //    }
        }
    }
    
    func found(code: String) {
        do {
            print(code)
            // convert String to NSData
            let data: Data = code.data(using: String.Encoding.utf8)!
            print("data converted")
            // convert NSData to 'AnyObject'
            do {
                 guard let result = (try JSONSerialization.jsonObject(with: data, options: [])
                    as? [String: String]) else {
                        print("error trying to convert data to JSON")
                        return
                }
                dict = result
                print("dict:  \(dict)")
//                convertToArray()
//                openPlatforms()
                getProfile(dict: dict)
        }
            catch let error as NSError {
                print("error \(error.localizedDescription)")
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
            var app = PagedAccounts.Accounts(accountId: -1, userId: -1, cognitoId: "", displayName: displayName, platform: "", url: url, username: "")
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
                nativeApps.append(app)
            case "Twitch":
                app.platform = platform
                nativeApps.append(app)
            case "Instagram":
                app.platform = platform
                nativeApps.append(app)
            case "LinkedIn":
                app.platform = platform
                nativeApps.append(app)
            case "Snapchat":
                app.platform = platform
                nativeApps.append(app)
            default:
                app.platform = platform
                safariApps.append(app)
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
    
    func getProfile(dict: [String:String]){
        //profiles = []
        let profileId = dict.first?.value
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        if let url = URL(string: "https://api.tc2pro.com/users/\(idString)/scans/\(profileId!)") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
            request.cachePolicy = .reloadIgnoringCacheData
            print(request)
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
                    print("decoding")
                    let decoder = JSONDecoder()
                    print("getting data")
                   // print(data)
                    print(response)
                    let profile = try decoder.decode(SingleProfile.self, from: data!)
                    //let profile = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) //as? SingleProfile
                    print(profile)
                    OperationQueue.main.addOperation {
                        print("in completion")
                        let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "SingleProfileViewController") as! SingleProfileViewController
                        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                        modalVC.allAccounts = profile.profile.accounts
                        modalVC.profile = profile.profile
                        modalVC.modalTransitionStyle = .crossDissolve
                        modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
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
}
