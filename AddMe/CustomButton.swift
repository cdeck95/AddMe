//
//  CustomButton.swift
//  AddMe
//
//  Created by Christopher Deck on 2/26/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    @IBInspectable var shadowColor = UIColor.black.cgColor
    @IBInspectable var shadowOffset = CGSize(width: 0.0, height: 2.0)
    @IBInspectable var masksToBounds = false
    @IBInspectable var shadowRadius = 1.0
    @IBInspectable var shadowOpacity:Float = 0.5
    @IBInspectable var cornerRadius: CGFloat = 2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //TODO: Code for our button
        
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        //layer.borderColor = CGColor.init(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        layer.masksToBounds = false
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

