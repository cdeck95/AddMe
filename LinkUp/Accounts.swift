//
//  Accounts.swift
//  LinkUp
//
//  Created by Christopher Deck on 9/4/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation

struct Accounts: Codable {
    
    var accountId: String
    var userId: String
    var cognitoId: String
    var displayName: String
    var platform: String
    var url: String
    var username: String
}
