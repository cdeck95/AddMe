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
        let profileId: String
        let accounts: [Accounts]
        let name: String
        let description: String
        let cognitoId: String
        let imageUrl: String
    }
    let profiles: [Profile]
}


    
    
//    struct Apps: Codable {
//
//        let _appId: String!
//        let _displayName: String?
//        let _platform: String?
//        let _uRL: String?
//        let _username: String?
//    }
    
//    init(dictionary: NSDictionary, accountIds: [String], imageIn: UIImage) {
//        self.accounts = accountIds
//        var tempAccounts: [Apps] = []
//        self.Accounts = tempAccounts
//        self.id = (dictionary["profileID"] as? String)!
//        print(self.id)
//        self.name = (dictionary["name"] as? String)!
//        print(self.Accounts)
//
//        self.backgroundColor = UIColor(red: 237/255, green: 250/255, blue: 253/255, alpha: 1)
//        self.descriptionLabel = (dictionary["info"] as? String)!
//        self.image = imageIn
//        print("RIGHT HERE")
//        let sema = DispatchSemaphore(value: 0);
//        //let idString = self.credentialsManager.identityID!
//        let idString = "us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85"
//        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts/")!)
//        print(request)
//        request.httpMethod = "GET"
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
//        let task = URLSession.shared.dataTask(with: request, completionHandler: {
//            data, response, error in
//            if error != nil {
//                print("error=\(error)")
//                sema.signal()
//                return
//            } else {
//                print("---no error----")
//            }
//            do {
//                print(data)
//                print("decoding")
//                let decoder = JSONDecoder()
//                print("getting data")
//                let JSONdata = try decoder.decode(JsonApp.self, from: data!)
//                print(JSONdata)
//                if(JSONdata.accounts.count == 0){
//                    print("no accounts")
//                } else {
//                    //=======
//                    for index in 0...JSONdata.accounts.count - 1 {
//                        let listOfAccountInfo = JSONdata.accounts[index]
//                        let displayName = listOfAccountInfo["displayName"]!
//                        let platform = listOfAccountInfo["platform"]!
//                        let url = listOfAccountInfo["url"]!
//                        let username = listOfAccountInfo["username"]!
//                        var appIdString = listOfAccountInfo["accountId"]!
//                        var appSwitchIsOn: String
//                        if(self.accounts.contains(appIdString)){
//                            appSwitchIsOn = "True"
//                        } else {
//                            appSwitchIsOn = "False"
//                        }
//                        print(appIdString)
//                        let appId = Int(appIdString)!//, radix: 16)!
//                        print(displayName)
//                        print(platform)
//                        print(url)
//                        print(appId)
//                        //print(username)
//                        let app = Apps()
//                        app?._appId = "\(appId)"
//                        app?._displayName = displayName
//                        app?._platform = platform
//                        app?._uRL = url
//                        app?._username = username
//                        app?._isSwitchOn = appSwitchIsOn
//                        print(app)
//                        self.Accounts.append(app!)
//                    }
//                    sema.signal()
//
//                }
//            } catch let error as NSError {
//                print(error)
//                sema.signal()
//            }
//        })
//        task.resume()
//        sema.wait(timeout: DispatchTime.distantFuture)
//    }

