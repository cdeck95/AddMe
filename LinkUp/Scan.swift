//
//  Scan.swift
//  LinkUp
//
//  Created by Christopher Deck on 9/3/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import UIKit

struct PagedScans: Codable {
    var scanned_profiles:[Scan]
    
    enum CodingKeys: String, CodingKey {
        case scanned_profiles = "scanned_profiles"
    }
    
    struct Scan:Codable{
        let profileId: Int
        let name: String
        let description: String
        let cognitoId: String
        let imageUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case profileId
            case description
            case cognitoId
            case imageUrl
            case name
        }
    }
}
