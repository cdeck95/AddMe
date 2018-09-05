//
//  Scan.swift
//  LinkUp
//
//  Created by Christopher Deck on 9/3/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import UIKit

class Scan {
    let id: String
    let name: String
    let descriptionLabel: String
    let profileId: String
    let profileImage: UIImage
    
    
    init(dictionary: NSDictionary, imageIn: UIImage) {
        self.id = (dictionary["id"] as? String)!
        self.profileId = (dictionary["profileID"] as? String)!
        self.name = (dictionary["name"] as? String)!
        self.descriptionLabel = (dictionary["descriptionLabel"] as? String)!
        self.profileImage = imageIn
    }
}
