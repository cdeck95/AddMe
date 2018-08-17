//
//  Extensions.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/16/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import UIKit

//Function to create a color from RGB and Computed property to get a Random UIColor based on this UIColorFromRGB method.
extension UIColor {
    
    class func colorFromRGB(_ r: Int, g: Int, b: Int) -> UIColor {
        return UIColor(red: CGFloat(Float(r) / 255), green: CGFloat(Float(g) / 255), blue: CGFloat(Float(b) / 255), alpha: 1)
    }
    
    class var random: UIColor {
        switch arc4random() % 13 {
        case 0: return UIColor.colorFromRGB(85, g: 0, b: 255)
        case 1: return UIColor.colorFromRGB(170, g: 0, b: 170)
        case 2: return UIColor.colorFromRGB(85, g: 170, b: 85)
        case 3: return UIColor.colorFromRGB(0, g: 85, b: 0)
        case 4: return UIColor.colorFromRGB(255, g: 170, b: 0)
        case 5: return UIColor.colorFromRGB(255, g: 85, b: 0)
        default : return UIColor.black //Not going to be called
        }
    }
}
