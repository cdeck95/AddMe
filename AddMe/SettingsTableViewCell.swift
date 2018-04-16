//
//  SettingsTableViewCell.swift
//  AddMe
//
//  Created by Tom Miller on 4/10/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.gray
    @IBInspectable var shadowOpacity: Float = 0.3
    @IBOutlet weak var NameLabel: UILabel!
    
    
    @IBOutlet var usersNameForApp: UILabel!
    @IBOutlet var appName: UILabel!
    
    override func awakeFromNib() {
        print("AppTableViewCell.swift awakeFromNib()")
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        print("AppTableViewCell.swift setSelected()")
        super.setSelected(selected, animated: animated)
        
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

