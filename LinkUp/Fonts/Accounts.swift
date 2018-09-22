//
//  Accounts.swift
//  LinkUp
//
//  Created by Christopher Deck on 9/4/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation

struct PagedAccounts:Codable {
    struct Accounts: Codable {
        
        var accountId: Int
        var userId: Int
        var cognitoId: String
        var displayName: String
        var platform: String
        var url: String
        var username: String
        // var isSwitchOn = false
        
        enum CodingKeys: String, CodingKey {
            case accountId
            case userId
            case displayName
            case cognitoId
            case platform
            case url
            case username
        }
    }
    var accounts:[Accounts]
}

