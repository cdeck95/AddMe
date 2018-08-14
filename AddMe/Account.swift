//
//  Account.swift
//  AddMe
//
//  Created by Christopher Deck on 8/11/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

enum AccountType: String {
    typealias RawValue = String
    
    case Twitter, Instagram, Snapchat, LinkedIn, Twitch, Facebook, Xbox, PSN, GooglePlus, Custom
    static let order:[AccountType] = [.Twitter, .Instagram, .Snapchat, .LinkedIn, .Twitch, .Facebook, .Xbox, .PSN, .GooglePlus, .Custom]
}

extension AccountType: Comparable {
    static func < (lhs: AccountType, rhs: AccountType) -> Bool {
        guard let rhsIndex = (order.index { rhs == $0 }) else { return false }
        guard let lhsIndex = (order.index { lhs == $0 }) else { return false }
        return lhsIndex < rhsIndex
    }
      
}
