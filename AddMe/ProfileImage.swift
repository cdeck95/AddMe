//
//  ProfileImage.swift
//  AWSAuthCore
//
//  Created by Christopher Deck on 4/16/18.
//

import UIKit

class ProfileImage: UIImageView {

    
    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
   

}
