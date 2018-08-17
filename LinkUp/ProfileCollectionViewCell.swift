//
//  ProfileCollectionViewCell.swift
//  AddMe
//
//  Created by Christopher Deck on 8/16/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import SwipingCarousel

class ProfileCollectionViewCell: SwipingCarouselCollectionViewCell {
    
    var accounts: [Apps]!
    var qrCodeString: String!
    @IBOutlet var editButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBInspectable var cornerRadius: CGFloat = 8
    @IBInspectable var shadowOffsetWidth: Int = 4
    @IBInspectable var shadowOffsetHeight: Int = 4
    @IBInspectable var shadowColor: UIColor? = UIColor.gray
    @IBInspectable var shadowOpacity: Float = 0.3
    
    @IBOutlet var descLabel: UILabel!
    
    static let reuseIdentifier = "ProfileCollectionViewCell"
//    static var nib: UINib {
//        get {
//            return UINib(nibName: "ProfileCollectionViewCell", bundle: nil)
//        }
//    }
    
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
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.masksToBounds = true
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
        profileImage.image = card.image
        profileImage.layer.borderWidth = 2
        profileImage.layer.borderColor = Color.glass.value.cgColor
        profileImage.layer.cornerRadius = 6
        profileImage.clipsToBounds = true
        nameLabel.text = card.name
        descLabel.text = card.descriptionLabel
        backgroundColor = card.backgroundColor
        accounts = card.Accounts
        qrCodeString = card.qrCodeString
        print("populate with complete")
    }
    
}
