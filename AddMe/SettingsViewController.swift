//
//  SettingsViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/25/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSCognito

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    // Test fields for DB
    @IBOutlet var userIdTextBox: UITextField!
    @IBOutlet var displayNameTextBox: UITextField!
    @IBOutlet var platformTextBox: UITextField!
    @IBOutlet var urlTextBox: UITextField!
    var onButtonTapped : (() -> Void)? = nil
    private let refreshControl = UIRefreshControl()
    
    
    let collectionView: UICollectionView = {
        let frame = CGRect(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2, width: UIScreen.main.bounds.size.width / 2, height: UIScreen.main.bounds.size.height / 2)
        let col = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        col.layer.borderColor = UIColor.red.cgColor
        col.layer.borderWidth = 1.0
        col.backgroundColor = UIColor.yellow
        return col
    }()
    
    let switchView = UISwitch()

    
    
    @IBOutlet var settingsAppsTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("SETTINGS tableView() return cellSwitches.count")
        return apps.count
    }
    
    // This is where the table cells on the main page are modeled from.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("creating cells for table view in settings")
        let cell:SettingsTableViewCell = settingsAppsTableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableViewCell
        cell.appName.text = apps[indexPath.row]._displayName!
        cell.appID = Int(apps[indexPath.row]._userId!)
        cell.onButtonTapped = {
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "EditAppViewController") as! EditAppViewController
            VC1.AppID = cell.appID
            self.navigationController!.showDetailViewController(VC1, sender: cell)
            
        }
        return cell
    }
    
//    var sideMenuViewController = SideMenuViewController()
//    var isMenuOpened:Bool = false
    var dataset: AWSCognitoDataset!
    var credentialsManager = CredentialsManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        sideMenuViewController = storyboard!.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
//        sideMenuViewController.view.frame = UIScreen.main.bounds
        let syncClient = AWSCognito.default()
        dataset = syncClient.openOrCreateDataset("AddMeDataSet\(credentialsManager.identityID)")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            settingsAppsTableView.refreshControl = refreshControl
        } else {
            settingsAppsTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshAppData(_:)), for: .valueChanged)
        switchView.frame = CGRect(x: 0, y: 20, width: 10, height: 5)
        switchView.addTarget(self, action: #selector(switched), for: .valueChanged)
        
        view.addSubview(switchView)
        //view.addSubview(collectionView)
    }
    
    @objc func switched(s: UISwitch){
        let origin: CGFloat = s.isOn ? view.frame.height : 50
        UIView.animate(withDuration: 0.35) {
            self.collectionView.frame.origin.y = origin
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        print("----in settings view will appear----")
//        if(isMenuOpened == true){
//            isMenuOpened = false
//            sideMenuViewController.willMove(toParentViewController: nil)
//            sideMenuViewController.view.removeFromSuperview()
//            sideMenuViewController.removeFromParentViewController()
//        }
        //cellSwitches = []
        self.tabBarController?.tabBar.isHidden = false
        refreshAppData(self)
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Send in info
    @IBAction func updateStuff(_ sender: Any) {
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/setUserInfo.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(userIdTextBox.text!)&b=\(displayNameTextBox.text!)&c=\(platformTextBox.text!)&d=\(urlTextBox.text!)"
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
    
    // This will allow you to make your own SQL and run it through the server. Just make a string for 'a' and then for each variable that you
    //  want to be returned, set it to "Y", if you don't want it to be returned, set it to anything else.
    @IBAction func runCustomSQL(_ sender: Any)
    {
        //$customSQL = $_POST['a'];
        //$wantUserId = $_POST['b'];
        //$wantUsername = $_POST['c'];
        //$wantDisplayName = $_POST['d'];
        //$wantPlatform = $_POST['e'];
        //$wantURL = $_POST['f'];
        let customSqlExample = "SELECT * FROM Users"
        
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/custom.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(customSqlExample)&b=Y&c=Y&d=N&e=Y&f=N"
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
    
    // Send in user Id to get back all the info for that user
    @IBAction func GetUserInfo(_ sender: Any) {
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/getUserInfo.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(userIdTextBox.text!)"
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
    
    @IBAction func addUser(_ sender: Any) {
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/addNewUser.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(displayNameTextBox.text!)&b=\(platformTextBox.text!)&c=\(urlTextBox.text!)&d=\(userIdTextBox.text!)"
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
    
    // Just here
    //https://tommillerswebsite.000webhostapp.com/AddMe/addNewUser.php      SEND IN ALL BUT ID
    //https://tommillerswebsite.000webhostapp.com/AddMe/getUserInfo.php     SEND IN ID
    //https://tommillerswebsite.000webhostapp.com/AddMe/setUserInfo.php     SEND IN ALL 4
    
    
//    @IBAction func menuClicked(_ sender: Any) {
//        if(isMenuOpened){
//            isMenuOpened = false
//            sideMenuViewController.willMove(toParentViewController: nil)
//            sideMenuViewController.view.removeFromSuperview()
//            sideMenuViewController.removeFromParentViewController()
//        }
//        else{
//            isMenuOpened = true
//            self.addChildViewController(sideMenuViewController)
//            self.view.addSubview(sideMenuViewController.view)
//            sideMenuViewController.didMove(toParentViewController: self)
//        }
//        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
//    }

    
    // TODO: Probably should add a Confirm Delete? button.
    @IBAction func deleteApps(_ sender: Any) {

        let alertController = UIAlertController(title: "Delete All Apps", message: "WARNING: This will delete all apps from your profile. This is not able to be undone.", preferredStyle: .alert)
        // Create OK button
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            // Code in this block will trigger when OK button tapped.
            let idString = self.credentialsManager.identityID!
            print(idString)
            var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/deleteUser.php")!)
            request.httpMethod = "POST"
            let postString = "a=\(idString)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request, completionHandler: {
                data, response, error in
                if error != nil {
                    print("error=\(error)")
                    return
                } else {
                    print("---no error----")
                }
                
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(responseString)
                
            })
            task.resume()
            self.settingsAppsTableView.reloadData() // Why this no update?!
        }
        alertController.addAction(OKAction)
        
        // Create Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            // Code in this block will trigger when cancel is tapped...most likely no code though.
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:nil)

        let idString = self.credentialsManager.identityID!
        print(idString)
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/deleteUser.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(idString)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            } else {
                print("---no error----")
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(responseString)
            
        })
        task.resume()
        refreshAppData(self)
    }
    
    @objc private func refreshAppData(_ sender: Any) {
        // Fetch Weather Data
        print("refreshAppData()")
        loadAppsFromDB()
        settingsAppsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func loadAppsFromDB() {
        var returnList: [Apps] = []
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/getUserInfo.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(idString)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                sema.signal()
                return
            } else {
                print("---no error----")
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            let lines = responseOne!.components(separatedBy: "\n")
            print(lines)
            
            // Goes through and picks out the platforms.
            if (lines.count > 3){
                for index in stride(from:0, to: lines.count-1, by: 4) {
                    print(index)
                    let app = Apps()
                    app?._userId = lines[index]
                    app?._displayName = lines[index+1]
                    app?._platform = lines[index+2]
                    app?._uRL = lines[index+3]
                    print(app)
                    returnList.append(app!)
                }
                apps = returnList
                sema.signal();
            }
            else {
                apps = returnList
                sema.signal()
            }
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        self.settingsAppsTableView.reloadData()
    }
}
