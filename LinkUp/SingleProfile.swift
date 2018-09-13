//
//  SingleProfile.swift
//  LinkUp
//
//  Created by Christopher Deck on 9/11/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation

struct SingleProfile: Codable {
    var profile: Profile
    
    struct Profile: Codable {
        let profileId: Int
        let accounts: [PagedAccounts.Accounts]
        let name: String
        let description: String
        let cognitoId: String
        let imageUrl: String?
        
//        enum CodingKeys: String, CodingKey {
//            case profileId
//            case accounts
//            case description
//            case cognitoId
//            case imageUrl
//            case name
//        }
    }
        
}
