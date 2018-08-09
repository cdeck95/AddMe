//
//  SettingsViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/25/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSCognito
import CDAlertView

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    // Test fields for DB
    @IBOutlet var userIdTextBox: UITextField!
    @IBOutlet var displayNameTextBox: UITextField!
    @IBOutlet var platformTextBox: UITextField!
    @IBOutlet var urlTextBox: UITextField!
    var onButtonTapped : (() -> Void)? = nil
    private let refreshControl = UIRefreshControl()
    var credentialsManager = CredentialsManager.sharedInstance
    var dataset: AWSCognitoDataset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let syncClient = AWSCognito.default()
        dataset = syncClient.openOrCreateDataset("AddMeDataSet\(credentialsManager.identityID)")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
        self.credentialsManager.createCredentialsProvider()
        
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
        cell.appID = apps[indexPath.row]._appId!
        
        print(cell.appID)
        cell.onButtonTapped = {
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "EditAppViewController") as! EditAppViewController
            VC1.AppID = cell.appID!
            self.navigationController!.showDetailViewController(VC1, sender: cell)
        }
        return cell
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


    
    @IBAction func deleteApps(_ sender: Any) {
        let alert = CDAlertView(title: "Deleting All Apps", message: "Are you sure you wish to delete all apps?", type: .warning)
        let doneAction = CDAlertViewAction(title: "Sure! 💪")
        alert.add(action: doneAction)
        let nevermindAction = CDAlertViewAction(title: "Nevermind 😬")
        alert.add(action: nevermindAction)
        alert.show()
    }
    
        
    func deleteAllApps(){
            print("deleting all apps")
            let idString = self.credentialsManager.identityID!
            var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts")!)
            request.httpMethod = "DELETE"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            
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

    
    @objc private func refreshAppData(_ sender: Any) {
        // Fetch Weather Data
        print("refreshAppData()")
        loadAppsFromDB()
        settingsAppsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    ////////////////////////////// BEGINNING OF JSON ///////////////////////////////////
    
    // TomMiller 2018/06/27 - Added struct to interact with JSON
    struct JsonApp: Decodable {
        //["{\"accounts\":[{\"cognitoId\":\"us-east-1:bafa67f1-8631-4c47-966d-f9f069b2107c\",\"displayName\":\"tomTweets\",\"platform\":\"Twitter\",\"url\":\"http://www.twitter.com/TomsTwitter\"}]}", ""]
        let accounts: [[String: String]]
    }
    
    var JsonApps = [JsonApp]()
    ////////////////////////////// END OF JSON ///////////////////////////////////
    
    ///////////////////////////// NEW STUFF /////////////////////////////////
    func loadAppsFromDB() {
        print("RIGHT HERE")
        var returnList: [Apps] = []
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts")!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        
        //        let postString = "{\"user\": {\"cognitoId\": \"\(idString)\"}}"
        //        print(postString)
        //        request.httpBody = postString.data(using: String.Encoding.utf8)
        //        print(request.httpBody)
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
                print("decoding")
                let decoder = JSONDecoder()
                print("getting data")
                let JSONdata = try decoder.decode(JsonApp.self, from: data!)
                //=======
                for index in 0...JSONdata.accounts.count - 1 {
                    let listOfAccountInfo = JSONdata.accounts[index]
                    let displayName = listOfAccountInfo["displayName"]!
                    let platform = listOfAccountInfo["platform"]!
                    let url = listOfAccountInfo["url"]!
                    let username = listOfAccountInfo["username"]!
                    var appIdString = listOfAccountInfo["accountId"]!
//                    if(appIdString.prefix(2) == "0x"){
//                        appIdString.removeFirst(2)
//                    }
                    let appId = Int(appIdString)!//, radix: 16)!
                    print(displayName)
                    print(platform)
                    print(url)
                    print(appId)
                    print(username)
                    let app = Apps()
                    app?._appId = "\(appId)"
                    app?._displayName = displayName
                    app?._platform = platform
                    app?._uRL = url
                    app?._username = username
                    print(app)
                    returnList.append(app!)
                }
                apps = returnList
                sema.signal();
                //=======
            } catch let err {
                print("Err", err)
                apps = returnList
                sema.signal(); // none found TODO: do something better than this shit.
            }
            print("Done")
            /////////////////////////
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        self.settingsAppsTableView.reloadData()
    }
}
