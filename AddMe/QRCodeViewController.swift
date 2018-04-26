//
//  QRCodeViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/25/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSCognito
import Foundation

class QRCodeViewController: UIViewController {

    @IBOutlet weak var QRCode: UIImageView!
//    var sideMenuViewController = SideMenuViewController()
//    var isMenuOpened:Bool = false
    var dataset: AWSCognitoDataset!
    var credentialsManager = CredentialsManager.sharedInstance
    var datasetManager = Dataset.sharedInstance
    var qrCode:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        sideMenuViewController = storyboard!.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
//        sideMenuViewController.view.frame = UIScreen.main.bounds
        
        // Initialize the Cognito Sync client
        let syncClient = AWSCognito.default()
        dataset = syncClient.openOrCreateDataset("AddMeDataSet\(credentialsManager.identityID)")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        guard let jsonStringAsArray: String = dataset.string(forKey: "jsonStringAsArray")
//            else {
//                print("code has not been created yet")
//                let image = UIImage(named: "launch_logo")
//                QRCode.image = image
//                return
//        }
//        print("json from data set: \(jsonStringAsArray)")
//        qrCode = generateQRCode(from: jsonStringAsArray)
//        QRCode.image = qrCode
        createQRCode(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        //Convert string to data
        let stringData = string.data(using: String.Encoding.utf8)
        
        //Generate CIImage
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(stringData, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciImage = filter?.outputImage else { return nil }
        
        //Scale image to proper size
       // let scale = CGFloat(size) / ciImage.extent.size.width
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        //Convert to CGImage
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return nil }
        
        //Finally return the UIImage
        return UIImage(cgImage: cgImage)
      //  let data = string.data(using: String.Encoding.ascii)
        
//        if let filter = CIFilter(name: "CIQRCodeGenerator") {
//            filter.setValue(data, forKey: "inputMessage")
//            let transform = CGAffineTransform(scaleX: 3, y: 3)
//
//            if let output = filter.outputImage?.transformed(by: transform) {
//                return UIImage(ciImage: output)
//            }
//        }
//
//        return nil
    }
//    
//    @IBAction func menuClicked(_ sender: Any) {
//        if(isMenuOpened){
//            isMenuOpened = false
//            sideMenuViewController.willMove(toParentViewController: nil)
//            sideMenuViewController.view.removeFromSuperview()
//            sideMenuViewController.removeFromParentViewController()
//        }
//        else{
//            isMenuOpened = true
//            self.addChildViewController(sideMenuViewController)
//            self.view.addSubview(sideMenuViewController.view)
//            sideMenuViewController.didMove(toParentViewController: self)
//        }
//        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
//    }
    
    @IBAction func scan(_ sender: Any) {
        let scannerVC = ScannerViewController()
        self.navigationController?.pushViewController(scannerVC, animated: true)
    }
    

    @IBAction func createQRCode(_ sender: Any) {
        var jsonStringAsArray = "{\n"
        print("createQRCode()")
        if(cellSwitches.count > 0){
            for index in 0...cellSwitches.count - 1{
                let isSelectedForQRCode = cellSwitches[index].appSwitch.isOn
                let appID = cellSwitches[index].id
                print(appID)
                print(isSelectedForQRCode)
                if (isSelectedForQRCode){
                    for app in apps {
                        if(Int(app._userId!) == appID){
                            jsonStringAsArray += "\"\(app._userId!)\": \"\(app._uRL!)\",\n"
                        } else {
                            print("app not found to make QR code")
                        }
                    }
                }
            }
        } else {
            print("no apps - casnnot create code")
        }
        jsonStringAsArray += "}"
        let result = jsonStringAsArray.replacingLastOccurrenceOfString(",",
                                                                       with: "")
        print(result)
        if(datasetManager.dataset != nil){
            datasetManager.dataset.setString(result, forKey: "jsonStringAsArray")
        }
        QRCode.image = generateQRCode(from: result)
    }
    
    @IBAction func shareButtonClicked(sender: UIButton) {
        print("share button clicked")
        //let textToShare = "Swift is awesome!  Check out this website about it!"
       
            let objectsToShare = [QRCode.image] as [AnyObject]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
    }

}
