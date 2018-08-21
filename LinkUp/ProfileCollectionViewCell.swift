//
//  ProfileCollectionViewCell.swift
//  AddMe
//
//  Created by Christopher Deck on 8/16/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    var profileID: String!
    var accounts: [Apps]!
    var qrCodeString: String!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var descLabel: UILabel!
    
    static let reuseIdentifier = "ProfileCollectionViewCell"
    
    @IBOutlet var openButton: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // ...
    }
    
    func populateWith(card: Profile) {
        //This creates the shadows and modifies the cards a little bit
        contentView.layer.cornerRadius = 6.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        layer.shadowColor = Color.coral.value.cgColor //UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = true
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        
        profileID = card.id
        print("card profile id: \(profileID)")
        profileImage.image = card.image
        //profileImage.layer.borderWidth = 2
        //profileImage.layer.borderColor = Color.glass.value.cgColor
        //profileImage.layer.cornerRadius = 6
        profileImage.clipsToBounds = true
        nameLabel.text = card.name
        descLabel.text = "(\(card.descriptionLabel))"
        backgroundColor = card.backgroundColor
        accounts = card.Accounts
        qrCodeString = card.qrCodeString
        
        openButton.setImage(UIImage(named: "baseline_keyboard_arrow_right_black_18dp"), for: .normal)
        
        descLabel.isHidden = false
        print("populate with complete")
    }
    
}
