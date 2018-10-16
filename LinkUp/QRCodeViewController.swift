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
import EFQRCode
import FCAlertView

class QRCodeViewController: UIViewController,  FCAlertViewDelegate, HalfModalPresentable {

    @IBOutlet weak var QRCode: UIImageView!
    var dataset: AWSCognitoDataset!
    var credentialsManager = CredentialsManager.sharedInstance
    var datasetManager = Dataset.sharedInstance
    var qrCode:UIImage!
    var profileId:Int!
    var shouldShare:Bool = false
    
    // Param
    var inputCorrectionLevel = EFInputCorrectionLevel.h
    var size: EFIntSize = EFIntSize(width: 1024, height: 1024)
    var magnification: EFIntSize? = EFIntSize(width: 9, height: 9)
    var backColor = UIColor.white
    var frontColor = UIColor.black
    var icon: UIImage? = nil
    var iconSize: EFIntSize? = nil
    var watermarkMode = EFWatermarkMode.scaleAspectFill
    var mode: EFQRCodeMode = .none
    var binarizationThreshold: CGFloat = 0.5
    var pointShape: EFPointShape = .square
    
    // MARK:- Not commonly used
    var foregroundPointOffset: CGFloat = 0
    var allowTransparent: Bool = true
    
    @IBOutlet var shareButton: UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Initialize the Cognito Sync client
//        let syncClient = AWSCognito.default()
//        dataset = syncClient.openOrCreateDataset("AddMeDataSet\(credentialsManager.identityID)")
//        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
//            // Your handler code here
//            return nil
//        }
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
    
    func generateQRCode(from string: String) -> UIImage? {
        if let tryImage = EFQRCode.generate(
            content: "\(profileId)",
           // backgroundColor: Color.coral.value.cgColor,
            foregroundColor: Color.bondiBlue.value.cgColor,
            watermark: UIImage(named: "AddMeLogo-1.png")?.toCGImage()
            ) {
            print("Create QRCode image success: \(tryImage)")
            return UIImage(cgImage: tryImage)
        } else {
            print("Create QRCode image failed!")
            return nil
        }
        
        //Convert string to data
//        let stringData = string.data(using: String.Encoding.utf8)
//
//        //Generate CIImage
//        let filter = CIFilter(name: "CIQRCodeGenerator")
//        filter?.setValue(stringData, forKey: "inputMessage")
//        filter?.setValue("H", forKey: "inputCorrectionLevel")
//        guard let ciImage = filter?.outputImage else { return nil }
//      //  var newCiImage = ciImage.replace(colorOld: EFUIntPixel(), colorNew: EFUIntPixel(red: 1,green: 82,blue: 73,alpha: 1))
//
//
//        //Scale image to proper size
//       // let scale = CGFloat(size) / ciImage.extent.size.width
//        let transform = CGAffineTransform(scaleX: 3, y: 3)
//        let scaledCIImage = ciImage.transformed(by: transform)
//
//        //Convert to CGImage
//        let ciContext = CIContext()
//        guard let cgImage = ciContext.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return nil }
//
//        //Finally return the UIImage
//        return UIImage(cgImage: cgImage)
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
        //QRCode.image = generateQRCode(from: qrCodeString)
    }
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
//            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
//            request.cachePolicy = .reloadIgnoringCacheData
//            print(request)
//
//            let task = URLSession.shared.dataTask(with: request, completionHandler: {
//                data, response, error in
//                if error != nil {
//                    print("error=\(error)")
//                    sema.signal()
//                    return
//                } else {
//                    print("---no error----")
//                }
//                //////////////////////// New stuff from Tom
//                do {
//                    print("decoding")
//                    let decoder = JSONDecoder()
//                    print("getting data")
//                    // print(data)
//                    print(response)
//                    let qrCodePNG = try decoder.decode(SingleProfile.self, from: data!)
//                    //let profile = (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)) //as? SingleProfile
//                    print(profile)
//                    OperationQueue.main.addOperation {
//                        print("in completion")
//                        let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "SingleProfileViewController") as! SingleProfileViewController
//                        // self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
//                        modalVC.allAccounts = profile.profile.accounts
//                        modalVC.profile = profile.profile
//                        modalVC.modalTransitionStyle = .crossDissolve
//                        // modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
//                        self.navigationController?.pushViewController(modalVC, animated: true)
//                    }
//                    sema.signal();
//                    //=======
//                } catch let err {
//                    print("Err", err)
//                    sema.signal(); // none found TODO: do something better than this shit.
//                }
//                print("Done")
//                /////////////////////////
//            })
//            task.resume()
//            sema.wait(timeout: DispatchTime.distantFuture)
            
            //send to another view controller to view profile
        
 //   }
    
    @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
        print("share button clicked")
       
        let objectsToShare = [QRCode.image] as [AnyObject]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.print, UIActivityType.assignToContact]
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        activityVC.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if (error == nil) {
                if (activityType == UIActivityType.saveToCameraRoll) {
                    let alert = FCAlertView()
                    alert.delegate = self
                    alert.colorScheme = Color.bondiBlue.value
                    alert.showAlert(inView: self,
                                    withTitle: "Success!",
                                    withSubtitle: "Your QR code is now saved to your camera roll!",
                                    withCustomImage: #imageLiteral(resourceName: "AddMeLogo-1"),
                                    withDoneButtonTitle: "Okay",
                                    andButtons: [])
                    
                    return
                } else if (activityType == UIActivityType.copyToPasteboard) {
                    let alert = FCAlertView()
                    alert.delegate = self
                    alert.colorScheme = Color.bondiBlue.value
                    alert.showAlert(inView: self,
                                    withTitle: "Success!",
                                    withSubtitle: "Your QR code is now copied to your Pasteboard!",
                                    withCustomImage: #imageLiteral(resourceName: "AddMeLogo-1"),
                                    withDoneButtonTitle: "Okay",
                                    andButtons: [])
                    return
                } else if (activityType == UIActivityType.message) {
                    self.dismiss(animated: false, completion: nil)
                }
            } else {
                let alert = FCAlertView()
                alert.delegate = self
                alert.colorScheme = Color.bondiBlue.value
                alert.showAlert(inView: self,
                                withTitle: "Uh Oh!",
                                withSubtitle: "Something went wrong. Please try again. If this keeps happening, contact our support team and we will be happy to assist.",
                                withCustomImage: #imageLiteral(resourceName: "AddMeLogo-1"),
                                withDoneButtonTitle: "Okay",
                                andButtons: [])
                print(error)
                return
            }
            
        }
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
