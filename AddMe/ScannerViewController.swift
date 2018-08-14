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

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, SFSafariViewControllerDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var dict: [String: String]!
    var twitter = 0
    var facebook = 0
    var keys: Dictionary<String, String>.Keys!
    var nativeApps = [Apps]()
    var safariApps = [Apps]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        self.navigationController?.navigationBar.isHidden  = true
        //tabBarController?.setupSwipeGestureRecognizers(allowCyclingThoughTabs: true)
        
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        dismiss(animated: true)
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
                convertToArray()
                openPlatforms()
        }
            catch let error as NSError {
                print(error.localizedDescription)
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
//        keys = dict.keys
//        print("keys")
//        if(dict.count > 0){
//
//            let currentKey = keys.first!
//            print("current key: \(currentKey)")
//            let currentURL = dict[currentKey]!
//            print("current url: \(currentURL)")
//            let url = URL(string: currentURL)
//            self.tabBarController?.hidesBottomBarWhenPushed = true
//            var platform = ""
//            if (currentURL.contains("twitter.com")){
//                platform = "Twitter"
//            } else if (currentURL.contains("twitch.tv")){
//                platform = "Twitch"
//            } else if (currentURL.contains("instagram.com")){
//                platform = "Instagram"
//            } else if (currentURL.contains("linkedin.com")){
//                platform = "LinkedIn"
//            } else if (currentURL.contains("snapchat.com")){
//                platform = "Snapchat"
//            } else {
//                platform = "other"
//            }
//
//
//            switch platform {
//                case "Twitter":
//                    openNative(url: url!, currentKey: currentKey)
//                case "Twitch":
//                    openNative(url: url!, currentKey: currentKey)
//                case "Instagram":
//                    openNative(url: url!, currentKey: currentKey)
//                case "LinkedIn":
//                    openNative(url: url!, currentKey: currentKey)
//                case "Snapchat":
//                    openNative(url: url!, currentKey: currentKey)
//                default:
//                    print("default")
//                    let svc = SFSafariViewController(url: url!)
//                    svc.delegate = self
//                    self.navigationController?.setNavigationBarHidden(true, animated: true)
//                    self.navigationController?.pushViewController(svc, animated: true)
//                }
//
//           dict.removeValue(forKey: currentKey)
//        }
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
        if(UIApplication.shared.canOpenURL(url)){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //dict.removeValue(forKey: currentKey)
            if nativeApps.count == 0 {
                print("popping...")
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                nativeApps.removeFirst()
                let mainQueue = DispatchQueue.main
                let deadline = DispatchTime.now() + .seconds(1)
                mainQueue.asyncAfter(deadline: deadline) {
                    self.openPlatforms()
                }
                
            }
        } else {
            print("opening in safari...")
            let svc = SFSafariViewController(url: url)
            svc.delegate = self
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.pushViewController(svc, animated: true)
        }
        
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
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
        else {
            openPlatforms()
        }
        dismiss(animated: true)
    }
}
