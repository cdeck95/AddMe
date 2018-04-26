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

class AddAppViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection: UICollectionView!
    var datasetManager = Dataset.sharedInstance
    //var reuseIdentifier:String = "collectionViewCell"
    //var store = DataStore.sharedInstance
    var appIDs = ["facebook", "instagram", "snapchat", "twitter", "linkedIn", "googlePlus"]
    let cellSizes = Array( repeatElement(CGSize(width:160, height:110), count: 6))
    var apps: [String]!
    var credentialsManager = CredentialsManager.sharedInstance
    
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInputDialog(key: String) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
   
        var alertController:UIAlertController!
//        switch key {
//            case "Facebook":
//                if AWSFacebookSignInProvider.sharedInstance().isLoggedIn {
//                    let alertController = UIAlertController(title: "Good News!", message: "You are already authenticated with Facebook. Please just enter your custom display name.", preferredStyle: .alert)
//
//                    //the confirm action taking the inputs
//                    let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
//
//                    //adding the action to dialogbox
//                    alertController.addAction(confirmAction)
//
//                    //finally presenting the dialog box
//                    self.present(alertController, animated: true, completion: nil)
//                    return
//                } else {
//                     alertController = UIAlertController(title: "Enter details", message: "Facebook special instructions", preferredStyle: .alert)
//                }
//            default:
                alertController = UIAlertController(title: "Enter details", message: "Enter your username", preferredStyle: .alert)
        //}
        
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            let username:String = (alertController.textFields?[1].text)!
            let displayName:String = (alertController.textFields?[0].text)!
            let userID:String = self.credentialsManager.identityID
            print(username)
            print(displayName)
            print(key)
            let app:Apps = Apps()
            app._userId = userID
            app._displayName = displayName
            app._platform = key
            switch key {
            case "Facebook":
                app._uRL = "http://facebook.com/\(username)"
            case "Twitter":
                app._uRL = "http://www.twitter.com/\(username)"
            case "Instagram":
                app._uRL = "http://www.instagram.com/\(username)"
            case "Snapchat":
                app._uRL = "http://www.snapchat.com/add/\(username)"
            case "LinkedIn":
                app._uRL = "http://www.linkedin.com/in/\(username)"
            case "GooglePlus":
                app._uRL = "http://plus.google.com/\(username)"
            default:
                print("unknown app found: \(key)")
            }
            
            if (self.verifyAppForUser(displayName: displayName, platform: key, url: app._uRL!, userName: app._userId!))
            {
                self.addToDB(userName: userID, displayName: displayName, platform: key, url: app._uRL!)
            }else {
                print("Can't add this app")
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Your Custom Display Name (i.e Personal Facebook)"
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Username"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
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
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collection.dequeueReusableCell(withReuseIdentifier: appIDs[indexPath.item], for: indexPath) as! CollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return cellSizes[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("User tapped on \(appIDs[indexPath.row])")
        switch appIDs[indexPath.row] {
        case "twitter":
            showInputDialog(key: "Twitter")
        case "snapchat":
            showInputDialog(key: "Snapchat")
        case "instagram":
            showInputDialog(key: "Instagram")
        case "facebook":
            showInputDialog(key: "Facebook")
        case "linkedIn":
            showInputDialog(key: "LinkedIn")
        case "googlePlus":
            showInputDialog(key: "GooglePlus")
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
    func addToDB(userName: String, displayName: String, platform: String, url: String){
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/addNewUser.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(displayName)&b=\(platform)&c=\(url)&d=\(userName)"
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
    }
    
    // This will check some things to avoid adding duplicate entries for a user.
    func verifyAppForUser(displayName: String, platform: String, url: String, userName: String) -> Bool {
        let sema = DispatchSemaphore(value: 0);
        var responseOne = ""
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/VerifyUserIsNew.php")!)
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
}
