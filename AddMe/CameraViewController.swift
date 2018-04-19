//
//  CameraViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 4/17/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
 
    @IBOutlet weak var loadedImage: UIImageView!
    let imagePicker = UIImagePickerController()
    var detector: CIDetector?
    
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            loadedImage.contentMode = .scaleAspectFit
            loadedImage.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
        self.detect()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func performQRCodeDetection(image: CIImage) -> (outImage: CIImage?, decode: String) {
        var resultImage: CIImage?
        var decode = ""
        if let detector = detector {
            let features = detector.features(in: image)
            for feature in features as! [CIQRCodeFeature] {
                resultImage = drawHighlightOverlayForPoints(image,
                                                            topLeft: feature.topLeft,
                                                            topRight: feature.topRight,
                                                            bottomLeft: feature.bottomLeft,
                                                            bottomRight: feature.bottomRight)
                decode = (feature.messageString)!
                print(decode)
            }
        }
        return (resultImage, decode)
    }
    
    func detect() {
        guard let qrCode = CIImage(image: loadedImage.image!) else {
            return
        }
        let result = performQRCodeDetection(image: qrCode)
        loadedImage.image = UIImage(ciImage: result.outImage!)
        let string = result.decode
        print(string)
    }
    
    func drawHighlightOverlayForPoints(_ image: CIImage, topLeft: CGPoint, topRight: CGPoint,
    bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
    var overlay = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
        overlay = overlay.cropped(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         parameters: [
    "inputExtent": CIVector(cgRect: image.extent),
    "inputTopLeft": CIVector(cgPoint: topLeft),
    "inputTopRight": CIVector(cgPoint: topRight),
    "inputBottomLeft": CIVector(cgPoint: bottomLeft),
    "inputBottomRight": CIVector(cgPoint: bottomRight)
    ])
        return overlay.composited(over: image)
    }
    
}

