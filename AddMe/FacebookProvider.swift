//
//  FacebookProvider.swift
//  AddMe
//
//  Created by Christopher Deck on 2/22/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import AWSFacebookSignIn
import FacebookCore

class FacebookProvider: NSObject, AWSIdentityProviderManager {
    func logins() -> AWSTask<NSDictionary> {
        if let token = AccessToken.current?.authenticationToken {
            return AWSTask(result: [AWSIdentityProviderFacebook:token])
        }
        return AWSTask(error:NSError(domain: "Facebook Login", code: -1 , userInfo: ["Facebook" : "No current Facebook access token"]))
    }
}
