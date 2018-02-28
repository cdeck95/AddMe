//
//  DataStore.swift
//  AddMe
//
//  Created by Christopher Deck on 2/27/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import UIKit

final class DataStore {
    
    static let sharedInstance = DataStore()
    fileprivate init() {}
    
    var apps: [CollectionViewCell] = []
    
    func storeApps(){
        let twitter:CollectionViewCell = CollectionViewCell()
        let image = UIImage(named: "twitter_icon")
        twitter.appImage = UIImageView(image: image)
        twitter.appLabel = "Twitter"
        
        let facebook:CollectionViewCell = CollectionViewCell()
        let image2 = UIImage(named: "fb-icon")
        facebook.appLabel =  "facebook"
        facebook.appImage = UIImageView(image: image2)
        
        apps.append(twitter)
        apps.append(facebook)
        print(apps)
    }
}

