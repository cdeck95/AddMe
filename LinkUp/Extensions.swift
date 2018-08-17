//
//  Extensions.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/16/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import UIKit

enum Color {
    
    case glass
    case chill
    case coral
    
    case bondiBlue
    case marina
//    case intermidiateBackground
//
//    case darkText
//    case lightText
//    case intermidiateText
//
//    case affirmation
//    case negation
    
    case custom(hexString: String, alpha: Double)
    
    func withAlpha(_ alpha: Double) -> UIColor {
        return self.value.withAlphaComponent(CGFloat(alpha))
    }
}

extension Color {
    
    var value: UIColor {
        var instanceColor = UIColor.clear
        
        switch self {
        case .glass:
            instanceColor = UIColor(hexString: "#EDFAFD")
        case .chill:
            instanceColor = UIColor(hexString: "#AED9DA")
        case .coral:
            instanceColor = UIColor(hexString: "#3DDAD7")
        case .bondiBlue:
            instanceColor = UIColor(hexString: "#2A93D5")
        case .marina:
            instanceColor = UIColor(hexString: "#135589")
        case .custom(let hexValue, let opacity):
            instanceColor = UIColor(hexString: hexValue).withAlphaComponent(CGFloat(opacity))
        }
        return instanceColor
    }
}

extension UIColor {
    /**
     Creates an UIColor from HEX String in "#363636" format
     
     - parameter hexString: HEX String in "#363636" format
     
     - returns: UIColor from HexString
     */
    convenience init(hexString: String) {
        
        let hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner          = Scanner(string: hexString as String)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}
