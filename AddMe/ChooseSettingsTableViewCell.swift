//
//  ChooseSettingsTableViewCell.swift
//  AddMe
//
//  Created by Christopher Deck on 4/21/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ChooseSettingsTableViewCell: UITableViewCell {

    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.gray
    @IBInspectable var shadowOpacity: Float = 0.3
    
    @IBOutlet weak var settingName: UILabel!
    
    var onButtonTapped : (() -> Void)? = nil
    
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
    
    @IBAction func showDetails(_ sender: UIButton) {
        print(sender.tag)
        if let onButtonTapped = self.onButtonTapped {
            onButtonTapped()
        }
    }

}
