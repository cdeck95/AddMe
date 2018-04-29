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

class QRCodeViewController: UIViewController, HalfModalPresentable {

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
      //  var newCiImage = ciImage.replace(colorOld: EFUIntPixel(), colorNew: EFUIntPixel(red: 1,green: 82,blue: 73,alpha: 1))

        
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
    
    @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
        print("share button clicked")
        //let textToShare = "Swift is awesome!  Check out this website about it!"
       
            let objectsToShare = [QRCode.image] as [AnyObject]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.addToReadingList]
            activityVC.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem 
            self.present(activityVC, animated: true, completion: nil)
    }

}

extension CIImage {
    
    // Replace color with another one
    // https://github.com/dstarsboy/TMReplaceColorHue/blob/master/TMReplaceColorHue/ViewController.swift
    func replace(colorOld: EFUIntPixel, colorNew: EFUIntPixel) -> CIImage {
        let cubeSize = 64
        let cubeData = { () -> [Float] in
            let selectColor = (Float(colorOld.red) / 255.0, Float(colorOld.green) / 255.0, Float(colorOld.blue) / 255.0, Float(colorOld.alpha) / 255.0)
            let raplaceColor = (Float(colorNew.red) / 255.0, Float(colorNew.green) / 255.0, Float(colorNew.blue) / 255.0, Float(colorNew.alpha) / 255.0)
            
            var data = [Float](repeating: 0, count: cubeSize * cubeSize * cubeSize * 4)
            var tempRGB: [Float] = [0, 0, 0]
            var newRGB: (r : Float, g : Float, b : Float, a: Float)
            var offset = 0
            for z in 0 ..< cubeSize {
                tempRGB[2] = Float(z) / Float(cubeSize) // blue value
                for y in 0 ..< cubeSize {
                    tempRGB[1] = Float(y) / Float(cubeSize) // green value
                    for x in 0 ..< cubeSize {
                        tempRGB[0] = Float(x) / Float(cubeSize) // red value
                        // Select colorOld
                        if tempRGB[0] == selectColor.0 && tempRGB[1] == selectColor.1 && tempRGB[2] == selectColor.2 {
                            newRGB = (raplaceColor.0, raplaceColor.1, raplaceColor.2, raplaceColor.3)
                        } else {
                            newRGB = (tempRGB[0], tempRGB[1], tempRGB[2], 1)
                        }
                        data[offset] = newRGB.r
                        data[offset + 1] = newRGB.g
                        data[offset + 2] = newRGB.b
                        data[offset + 3] = 1.0
                        offset += 4
                    }
                }
            }
            return data
        }()
        
        let data = cubeData.withUnsafeBufferPointer { Data(buffer: $0) } as NSData
        let colorCube = CIFilter(name: "CIColorCube")!
        colorCube.setValue(cubeSize, forKey: "inputCubeDimension")
        colorCube.setValue(data, forKey: "inputCubeData")
        colorCube.setValue(self, forKey: kCIInputImageKey)
        return colorCube.outputImage!
    }
}
