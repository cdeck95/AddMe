//
//  AddAppViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/27/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSCognito

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
            let appsData = UserDefaults.standard.array(forKey: "apps") as? [String]
            if appsData == nil {
                print("no apps yet")
                self.apps = []
            } else {
                self.apps = appsData
            }
            self.apps.append(key)
            print(self.apps)
            UserDefaults.standard.set(self.apps, forKey: "apps")
            self.dataset.setString(username, forKey: key)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Twitter Username"
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
            showInputDialog(key: "Facebook")
        default:
            print("error")
        }
    }
}
