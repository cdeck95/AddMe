//
//  ScannedTableViewCell.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/20/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ScannedTableViewCell: UITableViewCell {
    
    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var shadowOffsetWidth: Int = 4
    @IBInspectable var shadowOffsetHeight: Int = 4
    @IBInspectable var shadowColor: UIColor? = Color.glass.value
    @IBInspectable var shadowOpacity: Float = 0.3

    @IBOutlet var openButton: UIButton!
    @IBOutlet var appIcon: UIImageView!
    @IBOutlet var url: UILabel!
    
    override func awakeFromNib() {
        print("AppTableViewCell.swift awakeFromNib()")
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        print("AppTableViewCell.swift setSelected()")
        super.setSelected(selected, animated: animated)
        self.bringSubviewToFront(openButton)
        
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.masksToBounds = true
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }

}
