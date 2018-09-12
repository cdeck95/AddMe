//
//  Profile.swift
//  AddMe
//
//  Created by Christopher Deck on 8/16/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import UIKit

struct PagedProfile: Codable {
    struct Profile: Codable {
        let profileId: Int
        let accounts: [PagedAccounts.Accounts]
        let name: String
        let description: String
        let cognitoId: String
        let imageUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case profileId
            case accounts
            case description
            case cognitoId
            case imageUrl
            case name
        }
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.profileId = try container.decode(Int.self, forKey: .profileId)
            self.accounts = try container.decode([PagedAccounts.Accounts].self, forKey: .accounts)
            self.name = try container.decode(String.self, forKey: .name)
            self.description = try container.decode(String.self, forKey: .description)
            self.cognitoId = try container.decode(String.self, forKey: .cognitoId)
            self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        }
    }
    var profiles: [Profile]
}


    


