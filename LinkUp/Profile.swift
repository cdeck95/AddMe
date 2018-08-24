//
//  Profile.swift
//  AddMe
//
//  Created by Christopher Deck on 8/16/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import Foundation
import UIKit

class Profile {
    let id: String
    let Accounts: [Apps]
    let name: String
    let qrCodeString: String
    let backgroundColor: UIColor
    let descriptionLabel: String
    let image: UIImage
    
    public var description: String { return "Profile ID: \(self.id)" }
    
    ////////////////////////////// BEGINNING OF JSON ///////////////////////////////////
    
    // TomMiller 2018/06/27 - Added struct to interact with JSON
    struct JsonApp: Decodable {
        //["{\"accounts\":[{\"cognitoId\":\"us-east-1:bafa67f1-8631-4c47-966d-f9f069b2107c\",\"displayName\":\"tomTweets\",\"platform\":\"Twitter\",\"url\":\"http://www.twitter.com/TomsTwitter\"}]}", ""]
        let accounts: [[String: String]]
    }
    
    var JsonApps = [JsonApp]()
    ////////////////////////////// END OF JSON ///////////////////////////////////
    
    init(dictionary: NSDictionary, imageIn: UIImage) {
        var tempAccounts: [Apps] = []
        print("RIGHT HERE")
        let sema = DispatchSemaphore(value: 0);
        //let idString = self.credentialsManager.identityID!
        let idString = "us-east-1:528b7a0e-e5c6-4aa5-84aa-d96916e58f85"
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts/")!)
        print(request)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                sema.signal()
                return
            } else {
                print("---no error----")
            }
            do {
                print(data)
                print("decoding")
                let decoder = JSONDecoder()
                print("getting data")
                let JSONdata = try decoder.decode(JsonApp.self, from: data!)
                print(JSONdata)
                if(JSONdata.accounts.count == 0){
                    print("no accounts")
                } else {
                    //=======
                    for index in 0...JSONdata.accounts.count - 1 {
                        let listOfAccountInfo = JSONdata.accounts[index]
                        let displayName = listOfAccountInfo["displayName"]!
                        let platform = listOfAccountInfo["platform"]!
                        let url = listOfAccountInfo["url"]!
                        let username = listOfAccountInfo["username"]!
                        var appIdString = listOfAccountInfo["accountId"]!
                        //  var isSwitchOn = listOfAccountInfo["isSwitchOn"]!
                        //                    if(appIdString.prefix(2) == "0x"){
                        //                        appIdString.removeFirst(2)
                        //                    }
                        print(appIdString)
                        let appId = Int(appIdString)!//, radix: 16)!
                        print(displayName)
                        print(platform)
                        print(url)
                        print(appId)
                        //print(username)
                        let app = Apps()
                        app?._appId = "\(appId)"
                        app?._displayName = displayName
                        app?._platform = platform
                        app?._uRL = url
                        app?._username = username
                        app?._isSwitchOn = "True"
                        print(app)
                        tempAccounts.append(app!)
                    }
                    sema.signal()
                }
            } catch let error as NSError {
                print(error)
                sema.signal()
            }
        })
        task.resume()
        self.id = (dictionary["profileID"] as? String)!
        print(self.id)
        self.name = (dictionary["name"] as? String)!
        
        self.qrCodeString = (dictionary["qrCodeString"] as? String)!
        self.backgroundColor = UIColor(red: 237/255, green: 250/255, blue: 253/255, alpha: 1)
        self.descriptionLabel = (dictionary["info"] as? String)!
        self.image = imageIn
        sema.wait(timeout: DispatchTime.distantFuture)
        self.Accounts = tempAccounts
        print(self.Accounts)
    }
    
    //Load some demo information into the [savedCards] Array.
    static func loadCards() -> [Profile] {
        var savedCards = [Profile]()
        if let URL = Bundle.main.url(forResource: "Cards", withExtension: "plist") {
            if let cardsFromPlist = NSArray(contentsOf: URL) {
                for card in cardsFromPlist{
                    let newCard = Profile(dictionary: card as! NSDictionary, imageIn: UIImage(named: "AddMeLogo-2.png")!)
                    savedCards.append(newCard)
                }
            }
        }
        return savedCards
    }
}
