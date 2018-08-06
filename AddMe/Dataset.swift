//
//  Dataset.swift
//  AddMe
//
//  Created by Christopher Deck on 8/5/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import AWSCognito

final class Dataset {
    
    static let sharedInstance = Dataset()
    fileprivate init() {}
    
    var dataset: AWSCognitoDataset!
    var credentialsManager = CredentialsManager.sharedInstance
    
    func createDataset(){
        let syncClient = AWSCognito.default()
        dataset = syncClient.openOrCreateDataset("AddMeDataSet\(self.credentialsManager.identityID)")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
    }
}
