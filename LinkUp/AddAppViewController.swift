//
//  AddAppViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/27/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSCognito
import AWSFacebookSignIn
import AWSAuthUI
import FacebookCore
import AWSDynamoDB
import FBSDKLoginKit
import FCAlertView

class AddAppViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FCAlertViewDelegate, HalfModalPresentable {
    
    @IBOutlet weak var collection: UICollectionView!
    var datasetManager = Dataset.sharedInstance
    //var reuseIdentifier:String = "collectionViewCell"
    //var store = DataStore.sharedInstance
    var appIDs = ["Facebook", "Instagram", "Snapchat", "Twitter", "LinkedIn", "Google+", "Xbox", "PSN", "Twitch", "Custom"]
    let cellSizes = Array( repeatElement(CGSize(width:160, height:110), count: 10))
    var apps: [String]!
    var credentialsManager = CredentialsManager.sharedInstance
    var accountName: String!
    var accountPlatform: String!
    var accountUsername: String!
    
    override func viewDidLoad() {
        print("Loaded AddAppViewController")
        super.viewDidLoad()
        //store.storeApps()
        collection.delegate = self
        collection.dataSource = self
        // Initialize the Cognito Sync client
        
        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let indexSet = IndexSet(0...1)
//        self.collection.deleteSections(indexSet)
//        self.collection.reloadData()
        self.collection.flashScrollIndicators()   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInputDialog(key: String) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
   
        var alertController:UIAlertController!
        switch key {
            case "Facebook":
                if AWSFacebookSignInProvider.sharedInstance().isLoggedIn {
                    let alert = FCAlertView()
                    alert.delegate = self
                    alert.colorScheme = Color.bondiBlue.value
                    alert.addTextField(withPlaceholder: "Display Name (i.e. Business Facebook") { (text) in
                        print(text!)
                        self.accountName = text!
                        self.accountPlatform = key
                    }
                    
                    alert.showAlert(inView: self,
                                    withTitle: "Good News!",
                                    withSubtitle: "Facebook is already connected. Please just enter your custom display name.",
                                    withCustomImage: #imageLiteral(resourceName: "fb-icon"),
                                    withDoneButtonTitle: "Connect",
                                    andButtons: ["Cancel"])
                    
                    return
                } else {
                    let alert = FCAlertView()
                    alert.delegate = self
                    alert.colorScheme = Color.bondiBlue.value
                    alert.addTextField(withPlaceholder: "Display Name (i.e. Business Facebook") { (text) in
                        print(text!)
                        self.accountName = text!
                        self.accountPlatform = key
                    }
                    alert.addTextField(withPlaceholder: "Username") { (text) in
                        print(text!)
                        self.accountUsername = text!
                        self.accountPlatform = key
                    }
                    
                    alert.showAlert(inView: self,
                                    withTitle: "Connect Account",
                                    withSubtitle: "Please enter your account details below.",
                                    withCustomImage: #imageLiteral(resourceName: "fb-icon-2"),
                                    withDoneButtonTitle: "Connect",
                                    andButtons: ["Cancel"])
                    
                    return
                }
            case "Custom":
                let alert = FCAlertView()
                alert.delegate = self
                alert.colorScheme = Color.bondiBlue.value
                alert.addTextField(withPlaceholder: "Display Name (i.e. Business Facebook") { (text) in
                    print(text!)
                    self.accountName = text!
                    self.accountPlatform = key
                }
                alert.addTextField(withPlaceholder: "Username") { (text) in
                    print(text!)
                    self.accountUsername = text!
                    self.accountPlatform = key
                }
                
                alert.showAlert(inView: self,
                                withTitle: "Connect Account",
                                withSubtitle: "Please enter your account details below.",
                                withCustomImage: #imageLiteral(resourceName: "custom"),
                                withDoneButtonTitle: "Connect",
                                andButtons: ["Cancel"])
                return
            
            default:
                let alert = FCAlertView()
                alert.delegate = self
                alert.colorScheme = Color.bondiBlue.value
                alert.addTextField(withPlaceholder: "Display Name (i.e. Business Facebook") { (text) in
                    print(text!)
                    self.accountName = text!
                    self.accountPlatform = key
                }
                alert.addTextField(withPlaceholder: "Username") { (text) in
                    print(text!)
                    self.accountUsername = text!
                    self.accountPlatform = key
                }
                
                alert.showAlert(inView: self,
                                withTitle: "Connect Account",
                                withSubtitle: "Please enter your account details below.",
                                withCustomImage: #imageLiteral(resourceName: "twitter_icon"),
                                withDoneButtonTitle: "Connect",
                                andButtons: ["Cancel"])
                
            return
        }
        
//        func fcAlertDoneButtonClicked(_ alertView: FCAlertView){
//            print("small")
//            var url = ""
//            switch key {
//            case "Facebook":
//                url = "https://www.facebook.com/\(accountUsername)"
//            case "Twitter":
//                url = "https://www.twitter.com/\(accountUsername)"
//            case "Instagram":
//                url = "https://www.instagram.com/\(accountUsername)"
//            case "Snapchat":
//                url = "https://www.snapchat.com/add/\(accountUsername)"
//            case "LinkedIn":
//                url = "https://www.linkedin.com/in/\(accountUsername)"
//            case "GooglePlus":
//                url = "https://plus.google.com/\(accountUsername)"
//            case "Xbox":
//                let usernameURL = accountUsername.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//                url = "https://account.xbox.com/en-us/Profile?GamerTag=\(usernameURL!)"
//            case "PSN":
//                let usernameURL = accountUsername.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//                url = "https://my.playstation.com/profile/\(usernameURL!)"
//            case "Twitch":
//                url  = "https://m.twitch.tv/\(accountUsername)/profile"
//            case "Custom":
//                url  = "\(accountUsername)"
//            default:
//                print("unknown app found: \(key)")
//                url = "\(accountUsername)"
//            }
//            let account = PagedAccounts.Accounts(accountId: -1, userId: -1, cognitoId: credentialsManager.identityID, displayName: accountName, platform: accountPlatform, url: url, username: accountUsername)
//            self.addToDB(account: account)
//        }
//
//        func alertView(alertView: FCAlertView, clickedButtonIndex: Int, buttonTitle: String){
//            print("detecting button touch")
//            if title == "Button 1" {
//                // Perform Action for Button 1
//            }else if title == "Button 2"{
//                // Perform Action for Button 2
//            }
//        }
//
//
//
//
//        func FCAlertDoneButtonClicked(_ alertView: FCAlertView){
//            print("big")
//            var url = ""
//            switch key {
//            case "Facebook":
//                url = "https://www.facebook.com/\(accountUsername)"
//            case "Twitter":
//                url = "https://www.twitter.com/\(accountUsername)"
//            case "Instagram":
//                url = "https://www.instagram.com/\(accountUsername)"
//            case "Snapchat":
//                url = "https://www.snapchat.com/add/\(accountUsername)"
//            case "LinkedIn":
//                url = "https://www.linkedin.com/in/\(accountUsername)"
//            case "GooglePlus":
//                url = "https://plus.google.com/\(accountUsername)"
//            case "Xbox":
//                let usernameURL = accountUsername.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//                url = "https://account.xbox.com/en-us/Profile?GamerTag=\(usernameURL!)"
//            case "PSN":
//                let usernameURL = accountUsername.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//                url = "https://my.playstation.com/profile/\(usernameURL!)"
//            case "Twitch":
//                url  = "https://m.twitch.tv/\(accountUsername)/profile"
//            case "Custom":
//                url  = "\(accountUsername)"
//            default:
//                print("unknown app found: \(key)")
//                url = "\(accountUsername)"
//            }
//            let account = PagedAccounts.Accounts(accountId: -1, userId: -1, cognitoId: credentialsManager.identityID, displayName: accountName, platform: accountPlatform, url: url, username: accountUsername)
//            self.addToDB(account: account)
//        }
        
        
//        //the confirm action taking the inputs
//        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
//            //getting the input values from user
//            let username:String = (alertController.textFields?[1].text)!
//            let displayName:String = (alertController.textFields?[0].text)!
//            print(username)
//            print(displayName)
//            print(key)
//            let app:Apps = Apps()
//            app._displayName = displayName
//            app._platform = key
//            app._username = username
//            switch key {
//            case "Facebook":
//                app._uRL = "https://www.facebook.com/\(username)"
//            case "Twitter":
//                app._uRL = "https://www.twitter.com/\(username)"
//            case "Instagram":
//                app._uRL = "https://www.instagram.com/\(username)"
//            case "Snapchat":
//                app._uRL = "https://www.snapchat.com/add/\(username)"
//            case "LinkedIn":
//                app._uRL = "https://www.linkedin.com/in/\(username)"
//            case "GooglePlus":
//                app._uRL = "https://plus.google.com/\(username)"
//            case "Xbox":
//                let usernameURL = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//                app._uRL = "https://account.xbox.com/en-us/Profile?GamerTag=\(usernameURL!)"
//            case "PSN":
//                let usernameURL = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//                app._uRL = "https://my.playstation.com/profile/\(usernameURL!)"
//            case "Twitch":
//                app._uRL = "https://m.twitch.tv/\(username)/profile"
//            case "Custom":
//                app._uRL = "\(username)"
//            default:
//                print("unknown app found: \(key)")
//            }
//
//            //if (self.verifyAppForUser(displayName: displayName, platform: key, url: app._uRL!, userName: app._userId!))
//            //{
//            self.addToDB(cognitoId: self.credentialsManager.identityID, displayName: displayName, platform: key, url: app._uRL!, username: username)
//            //}else {
//            //    print("Can't add this app")
//            //}
//        }
//        alertController.addAction(confirmAction)
//        //finally presenting the dialog box
//        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentAlert(message: String){
        let alertController = UIAlertController(title: "Woah!", message: message, preferredStyle: .alert)

        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
        }

        //adding the action to dialogbox
        alertController.addAction(confirmAction)

        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
//
//    func alertView(alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
//
//        if title == "Button 1" {
//            // Perform Action for Button 1
//        }else if title == "Button 2"{
//            // Perform Action for Button 2
//        }
//    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: appIDs[indexPath.item], for: indexPath) as! CollectionViewCell
        cell.displayContent(title: appIDs[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return cellSizes[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("User tapped on \(appIDs[indexPath.row])")
        switch appIDs[indexPath.row] {
        case "Twitter":
            showInputDialog(key: "Twitter")
        case "Snapchat":
            showInputDialog(key: "Snapchat")
        case "Instagram":
            showInputDialog(key: "Instagram")
        case "Facebook":
            showInputDialog(key: "Facebook")
        case "LinkedIn":
            showInputDialog(key: "LinkedIn")
        case "Google+":
            showInputDialog(key: "GooglePlus")
        case "Xbox":
            showInputDialog(key: "Xbox")
        case "PSN":
            showInputDialog(key: "PSN")
        case "Twitch":
            showInputDialog(key: "Twitch")
        case "Custom":
            showInputDialog(key: "Custom")
        default:
            print("error")
        }
    }
    
    @IBAction func addApp(_ sender: Any) {
       
    }
    
    func getFBUserInfo(params: String, dataset: AWSCognitoDataset) {
        let request = GraphRequest(graphPath: "me", parameters: ["fields":params], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
            case .success(let value):
                print(value.dictionaryValue ?? "-1")
                let userID = value.dictionaryValue?["id"] as! String
                dataset.setString(userID, forKey: "userID")
                let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(userID)/picture?type=large")
                if let data = NSData(contentsOf: facebookProfileUrl!) {
                    // self.profilePicture.image = UIImage(data: data as Data)
                    
                }
                dataset.setString(value.dictionaryValue?["id"] as? String, forKey: "Facebook")
                print(value.dictionaryValue?["id"] as? String)
            case .failed(let error):
                print(error)
            }
        }
    }
    
    // Adds a users account to the DB.
    func addToDB(account: PagedAccounts.Accounts){
        let identityId = self.credentialsManager.identityID!
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(identityId)/accounts")!)
        print(request)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        let postString = "{\"displayName\": \"\(account.displayName)\", \"platform\": \"\(account.platform)\", \"url\": \"\(account.url)\", \"username\": \"\(account.username)\"}"
        print(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
        
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            print(responseOne!)
        })
        task.resume()
        let alert = FCAlertView()
        alert.delegate = self
        alert.colorScheme = Color.bondiBlue.value
        alert.showAlert(inView: self,
                        withTitle: "Success!",
                        withSubtitle: "Your account is now added to the database.",
                        withCustomImage: #imageLiteral(resourceName: "AddMeLogo-1"),
                        withDoneButtonTitle: nil,
                        andButtons: ["Ok"])
    }
    
    // This will check some things to avoid adding duplicate entries for a user.
    func verifyAppForUser(displayName: String, platform: String, url: String, userName: String) -> Bool {
        let sema = DispatchSemaphore(value: 0);
        var responseOne = ""
        var request = URLRequest(url:URL(string: "https://3dj5gbinck.execute-api.us-east-1.amazonaws.com/dev/users")!)
        request.httpMethod = "POST"
        let postString = "a=\(userName)&b=\(displayName)&c=\(platform)&d=\(url)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                sema.signal()
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            responseOne = responseString as! String as! String
            print(responseOne)
            sema.signal()
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        if (responseOne == "GOOD")
        {
            return true
        }
        self.presentAlert(message: responseOne)
        return false
    }
    
    @IBAction func maximizeButtonTapped(sender: AnyObject) {
        maximizeToFullScreen()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func loadAppsFromDB() -> [PagedAccounts.Accounts] {
        print("RIGHT HERE")
        var returnList: [PagedAccounts.Accounts] = []
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts")!)
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
            //////////////////////// New stuff from Tom
            do {
                let decoder = JSONDecoder()
                let parser = APIMessageParser(received: response.debugDescription, parent: self.inputViewController!)
                let JSONdata = try decoder.decode(PagedAccounts.self, from: data!)
                //=======
                for index in 0...JSONdata.accounts.count - 1 {
                    let account = JSONdata.accounts[index]
                    print(account)
                    returnList.append(account)
                }
                sema.signal();
                //=======
            } catch let err {
                print("Err", err)
                sema.signal(); // none found TODO: do something better than this shit.
            }
            print("Done")
            /////////////////////////
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        return returnList
    }
    
    func fcAlertDoneButtonClicked(_ alertView: FCAlertView!) {
        print("done button clicked")
        var url = ""
        if (self.accountUsername.count > 0 && self.accountPlatform.count > 0){
            switch self.accountPlatform {
            case "Facebook":
                url = "https://www.facebook.com/\(accountUsername!)"
            case "Twitter":
                url = "https://www.twitter.com/\(accountUsername!)"
            case "Instagram":
                url = "https://www.instagram.com/\(accountUsername!)"
            case "Snapchat":
                url = "https://www.snapchat.com/add/\(accountUsername!)"
            case "LinkedIn":
                url = "https://www.linkedin.com/in/\(accountUsername!)"
            case "GooglePlus":
                url = "https://plus.google.com/\(accountUsername!)"
            case "Xbox":
                let usernameURL = accountUsername!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                url = "https://account.xbox.com/en-us/Profile?GamerTag=\(usernameURL!)"
            case "PSN":
                let usernameURL = accountUsername!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                url = "https://my.playstation.com/profile/\(usernameURL!)"
            case "Twitch":
                url  = "https://m.twitch.tv/\(accountUsername!)/profile"
            case "Custom":
                url  = "\(accountUsername)"
            default:
                print("unknown app found: \(self.accountPlatform)")
                url = "\(accountUsername!)"
            }
            let account = PagedAccounts.Accounts(accountId: -1, userId: -1, cognitoId: credentialsManager.identityID, displayName: accountName, platform: accountPlatform, url: url, username: accountUsername!)
            self.addToDB(account: account)
        }else{
            print("Empty fields while adding new social media account")
        }
    }
}
