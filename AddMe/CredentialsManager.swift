//
//  CredentialsManager.swift
//  AddMe
//
//  Created by Christopher Deck on 3/5/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import AWSCognito


final class CredentialsManager {
    
    static let sharedInstance = CredentialsManager()
    fileprivate init() {}
    
    var credentialsProvider: AWSCognitoCredentialsProvider!
    var configuration: AWSServiceConfiguration!
    var identityID:String!
    
    func createCredentialsProvider(){
        credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                            identityPoolId:"us-east-1:99eed9b4-f0a9-4f6d-b34c-5f05a1a5fa6b")
        configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func setIdentityID(id: String){
        identityID = id
    }
}
