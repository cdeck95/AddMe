//
//  AddAppViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/27/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSCognito

class AddAppViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collection: UICollectionView!
    var dataset: AWSCognitoDataset!
    var reuseIdentifier:String = "collectionViewCell"
    var store = DataStore.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.storeApps()
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
        self.collection.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInputDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter details?", message: "Enter your username", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            let username = alertController.textFields?[0].text
            print(username)
            self.dataset.setString(username, forKey: "twitterUsername")
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
        print("count: \(store.apps.count)")
        return store.apps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        let app = store.apps[indexPath.row]
        print("in array method")
        print(app.appLabel)
        print(app.appImage.image)
        cell.displayContent(image: app.appImage, title: app.appLabel)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddAppViewController.connected(_:)))
        
        cell.appImage.isUserInteractionEnabled = true
        cell.appImage.tag = indexPath.row
        cell.appImage.addGestureRecognizer(tapGestureRecognizer)
        return cell
    }
    
    @objc func connected(_ sender:AnyObject){
        print("you tap image number : \(sender.view.tag)")
        switch sender.view.tag {
        case 0:
            //twitter
            showInputDialog()
        case 1:
            //snapchat
            showInputDialog()
        case 2:
            //instagram
            showInputDialog()
        case 3:
            //facebook
            showInputDialog()
        default:
            print("error")
        }
    }
}
