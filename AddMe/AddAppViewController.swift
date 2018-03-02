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

class AddAppViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection: UICollectionView!
    var dataset: AWSCognitoDataset!
    //var reuseIdentifier:String = "collectionViewCell"
    //var store = DataStore.sharedInstance
    var appIDs = ["facebook", "instagram", "snapchat", "twitter"]
    let cellSizes = Array( repeatElement(CGSize(width:160, height:110), count: 4))
    var apps: [String]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //store.storeApps()
        collection.delegate = self
        collection.dataSource = self
        // Initialize the Cognito Sync client
        let syncClient = AWSCognito.default()
        dataset = syncClient.openOrCreateDataset("AddMeDataSet")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
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
        let alertController = UIAlertController(title: "Enter details?", message: "Enter your username", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            let username = alertController.textFields?[0].text
            print(username!)
            print(key)
            var appsDataString = self.dataset.string(forKey: "apps")
            if(appsDataString == nil) {
                print("no apps yet")
                self.apps = []
            } else {
                let appsData: [String] = (appsDataString?.components(separatedBy: ","))!
                self.apps = appsData
                print(self.apps)
            }
            self.apps.append(key)
            appsDataString = self.apps.joined(separator: ",")
            print(appsDataString)
            self.dataset.setString(appsDataString, forKey: "apps")
            self.dataset.setString(username, forKey: key)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
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
            //twitter
            showInputDialog(key: "Twitter")
        case "snapchat":
            //snapchat
            showInputDialog(key: "Snapchat")
        case "instagram":
            //instagram
            showInputDialog(key: "Instagram")
        case "facebook":
            //facebook
            //showInputDialog(key: "Facebook")
            facebookInput(key: "Facebook")
        default:
            print("error")
        }
    }
    
    func facebookInput(key: String){
        if AWSFacebookSignInProvider.sharedInstance().isLoggedIn {
            let alertController = UIAlertController(title: "Good News!", message: "You are already authenticated with Facebook. Please reload the home screen.", preferredStyle: .alert)
            
            //the confirm action taking the inputs
            let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
            
            //adding the action to dialogbox
            alertController.addAction(confirmAction)
            //alertController.addAction(cancelAction)
            let appsData = UserDefaults.standard.array(forKey: "appsFacebook") as? [String]
            if appsData == nil {
                print("no apps yet")
                self.apps = []
            } else {
                self.apps = appsData
            }
            self.apps.append(key)
            print(self.apps)
            UserDefaults.standard.set(self.apps, forKey: "appsFacebook")
            //finally presenting the dialog box
            self.present(alertController, animated: true, completion: nil)
        } else {
            //login through facebook
            let alertController = UIAlertController(title: "Action Needed", message: "Please copy & paste the username for your facebook account. This is located in your profile url: \"www.facebook.com/[username here]\"", preferredStyle: .alert)
            
            
            //the confirm action taking the inputs
            let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
                //getting the input values from user
                let username = alertController.textFields?[0].text
                print(username!)
                print(key)
                var appsDataString = self.dataset.string(forKey: "apps")
                if(appsDataString == nil) {
                    print("no apps yet")
                    self.apps = []
                } else {
                    let appsData: [String] = (appsDataString?.components(separatedBy: ","))!
                    self.apps = appsData
                    print(self.apps)
                }
                self.apps.append(key)
                appsDataString = self.apps.joined(separator: ",")
                print(appsDataString)
                self.dataset.setString(appsDataString, forKey: "apps")
                self.dataset.setString(username, forKey: key)
            }
            
            //the cancel action doing nothing
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            //adding textfields to our dialog box
            alertController.addTextField { (textField) in
                textField.placeholder = "Enter Facebook Username"
            }
            
            //adding the action to dialogbox
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            //finally presenting the dialog box
            self.present(alertController, animated: true, completion: nil)
        }
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
}
