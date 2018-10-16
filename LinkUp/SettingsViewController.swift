//
//  SettingsViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/25/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSCognito
import FCAlertView
import Sheeeeeeeeet

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FCAlertViewDelegate{

    private let refreshControl = UIRefreshControl()
    var credentialsManager = CredentialsManager.sharedInstance
    var dataset: AWSCognitoDataset!
    var customView: UIView!
    var labelsArray: Array<UILabel> = []
    var newDisplayName:String = ""
    var newUsername:String = ""
    var account:PagedAccounts.Accounts!
    var flag:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tabBarController?.setupSwipeGestureRecognizers(allowCyclingThoughTabs: true)
        let syncClient = AWSCognito.default()
        dataset = syncClient.openOrCreateDataset("AddMeDataSet\(credentialsManager.identityID)")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
       // loadCustomRefreshContents()
        self.credentialsManager.createCredentialsProvider()
        settingsAppsTableView.layer.borderColor = UIColor.clear.cgColor
        settingsAppsTableView.layer.backgroundColor = UIColor.clear.cgColor
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.view.backgroundColor = Color.glass.value
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            settingsAppsTableView.refreshControl = refreshControl
        } else {
            settingsAppsTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshAppData(_:)), for: .valueChanged)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        if(section == 0){
            vw.backgroundColor = .clear
            let textView = UITextView()
            textView.text = "Social Accounts"
            textView.font = UIFont(name: "Trench", size: UIFont.labelFontSize)
            textView.textColor = .black
            textView.sizeToFit()
            textView.backgroundColor = .clear
            vw.addSubview(textView)
        } else {
            vw.backgroundColor = .clear
            let textView = UITextView()
            textView.text = "Social Accounts"
            textView.font = UIFont(name: "Trench", size: UIFont.labelFontSize)
            textView.textColor = .black
            textView.sizeToFit()
            textView.backgroundColor = .clear
            vw.addSubview(textView)
        }
        
        return vw
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("SETTINGS tableView() return cellSwitches.count")
        return apps.count
    }
    
    // This is where the table cells on the main page are modeled from.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("creating cells for table view in settings")
        let cell:SettingsTableViewCell = settingsAppsTableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
        cell.nameLabel.text = apps[indexPath.row].displayName
        cell.usernameLabel.text = "@\(apps[indexPath.row].username)"
        cell.appID = apps[indexPath.row].accountId
        cell.layer.backgroundColor = UIColor.white.cgColor
        
        switch apps[indexPath.row].platform {
        case "Facebook":
            cell.appImage.image = UIImage(named: "fb-icon")
        case "Twitter":
            cell.appImage.image = UIImage(named: "twitter_icon")
        case "Instagram":
            cell.appImage.image = UIImage(named: "Instagram_icon")
        case "Snapchat":
            cell.appImage.image = UIImage(named: "snapchat_icon")
        case "GooglePlus":
            cell.appImage.image = UIImage(named: "google_plus_icon")
        case "LinkedIn":
            cell.appImage.image = UIImage(named: "linked_in_logo")
        case "Xbox":
            cell.appImage.image = UIImage(named: "xbox")
        case "PSN":
            cell.appImage.image = UIImage(named: "play-station")
        case "Twitch":
            cell.appImage.image = UIImage(named: "twitch")
        case "Custom":
            cell.appImage.image = UIImage(named: "custom")
        default:
            cell.appImage.image = UIImage(named: "AppIcon")
        }
        
        print(cell.appID)
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actionSheet = createStandardActionSheet(indexPath: indexPath)
        actionSheet.present(in: self, from: self.view)
    }
    
    func createStandardActionSheet(indexPath: IndexPath) -> ActionSheet {
        let title = ActionSheetTitle(title: "Select an option")
        let item1 = ActionSheetItem(title: "Edit Display Name", value: "1", image: UIImage(named: "baseline_create_black_18pt"))
        let item2 = ActionSheetItem(title: "Edit Username", value: "2", image: UIImage(named: "baseline_create_black_18pt"))
        let deleteButton = ActionSheetDangerButton(title: "Delete Profile")
        let button = ActionSheetOkButton(title: "Cancel")
        return ActionSheet(items: [title, item1, item2, deleteButton, button]) { _, item in
            
            guard let value = item.value as? String else {
                if item is ActionSheetDangerButton {
                    self.deleteAccount(accountId: apps[indexPath.row].accountId)
                }
                return
            }
            
            self.account = apps[indexPath.row]
            
            if value == "1" {
                let alert = FCAlertView()
                alert.delegate = self
                alert.colorScheme = Color.bondiBlue.value
                let cell = self.settingsAppsTableView.cellForRow(at: indexPath) as! SettingsTableViewCell
                alert.addTextField(withPlaceholder: cell.nameLabel.text) { (text) in
                    self.settingsAppsTableView.deselectRow(at: indexPath, animated: true)
                    if(text != ""){
                        self.newDisplayName = text!
                        //self.account = apps[indexPath.row]
                        self.flag = 1
                        print(text!)
                    }
                    
                }
                
                alert.showAlert(inView: self,
                                withTitle: "Edit Account",
                                withSubtitle: "Please update your account information.",
                                withCustomImage: cell.appImage.image,
                                withDoneButtonTitle: "Update",
                                andButtons: ["Cancel"])
                return
            } else if value == "2" {
                let alert = FCAlertView()
                alert.delegate = self
                alert.colorScheme = Color.bondiBlue.value
                let cell = self.settingsAppsTableView.cellForRow(at: indexPath) as! SettingsTableViewCell
                alert.addTextField(withPlaceholder: cell.usernameLabel.text) { (text) in
                    self.settingsAppsTableView.deselectRow(at: indexPath, animated: true)
                    if(text != ""){
                        print(text!)
                        self.newUsername = text!
                      //  self.account = apps[indexPath.row]
                        self.flag = 2
                    }
                }
                
                alert.showAlert(inView: self,
                                withTitle: "Edit Account",
                                withSubtitle: "Please update your account username.",
                                withCustomImage: cell.appImage.image,
                                withDoneButtonTitle: "Update",
                                andButtons: ["Cancel"])
            }
        }
    }
    
    func fcAlertDoneButtonClicked(_ alertView: FCAlertView!) {
        if(flag == 2 && self.newUsername != ""){
            updateUsername()
        } else if (flag == 2 && self.newUsername == ""){
            let alert = FCAlertView()
            alert.delegate = self
            alert.colorScheme = Color.bondiBlue.value
            
            alert.showAlert(inView: self,
                            withTitle: "Error",
                            withSubtitle: "Please enter some text to update.",
                            withCustomImage: UIImage(named: "AppIcon-3"),
                            withDoneButtonTitle: nil,
                            andButtons: ["OK"])
            alert.hideDoneButton = true
            
        }
        if(flag == 1 && newDisplayName != ""){
            self.account.displayName = newDisplayName
            updateDisplayName()
        } else if (flag == 1 && newDisplayName == ""){
            let alert = FCAlertView()
            alert.delegate = self
            alert.colorScheme = Color.bondiBlue.value

            alert.showAlert(inView: self,
                            withTitle: "Error",
                            withSubtitle: "Please enter some text to update.",
                            withCustomImage: UIImage(named: "AppIcon-3"),
                            withDoneButtonTitle: nil,
                            andButtons: ["OK"])
             alert.hideDoneButton = true

        }
    }
    
    
    @objc func switched(s: UISwitch){
        let origin: CGFloat = s.isOn ? view.frame.height : 50
        UIView.animate(withDuration: 0.35) {
            self.collectionView.frame.origin.y = origin
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        print("----in settings view will appear----")
        self.tabBarController?.tabBar.isHidden = false
        refreshAppData(self)
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func deleteApps(_ sender: Any) {
//        let alert = CDAlertView(title: "Deleting All Apps", message: "Are you sure you wish to delete all accounts?", type: .warning)
//        let doneAction = CDAlertViewAction(title: "Sure! 💪",
//                                           font: UIFont.systemFont(ofSize: 17),
//                                           textColor: UIColor(red: 27 / 255, green: 169 / 255, blue: 225 / 255, alpha: 1),
//                                           backgroundColor: nil,
//                                           handler: { action in self.deleteAllApps()})
//        alert.add(action: doneAction)
//        let nevermindAction = CDAlertViewAction(title: "Nevermind 😬")
//        alert.add(action: nevermindAction)
//        alert.show()
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
    
//    // TomMiller 2018/06/27 - Added struct to interact with JSON
//    struct JsonApp: Decodable {
//        //["{\"accounts\":[{\"cognitoId\":\"us-east-1:bafa67f1-8631-4c47-966d-f9f069b2107c\",\"displayName\":\"tomTweets\",\"platform\":\"Twitter\",\"url\":\"http://www.twitter.com/TomsTwitter\"}]}", ""]
//        let accounts: [[String: String]]
//    }
//
//    var JsonApps = [JsonApp]()
//    ////////////////////////////// END OF JSON ///////////////////////////////////
    
    ///////////////////////////// NEW STUFF /////////////////////////////////
    func loadAppsFromDB() {
        print("RIGHT HERE")
        var returnList: [PagedAccounts.Accounts] = []
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
                let pagedAccounts = try decoder.decode(PagedAccounts.self, from: data!)
                //=======
                for index in 0...pagedAccounts.accounts.count - 1 {
                    let account = pagedAccounts.accounts[index]
                    returnList.append(account)
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
    
    ///////////////////////////// NEW STUFF /////////////////////////////////
    func updateDisplayName() {
        print("RIGHT HERE")
        var returnList: [PagedAccounts.Accounts] = []
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts/\(self.account.accountId)")!)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        
        let postString = "{\"displayName\": \"\(self.account.displayName)\", \"platform\": \"\(self.account.platform)\", \"url\": \"\(self.account.url)\", \"username\": \"\(self.account.username)\"}"
        print(postString)
        request.cachePolicy = .reloadIgnoringLocalCacheData
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
            //////////////////////// New stuff from Tom
            do {
                print("decoding")
                let decoder = JSONDecoder()
                print("getting data")
                let response = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, AnyObject>
                //=======
                print(response)
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
        loadAppsFromDB()
    }
    
    func updateUsername() {
//        print("RIGHT HERE")
//        let idString = self.credentialsManager.identityID!
//        print(idString)
       // let sema = DispatchSemaphore(value: 0);
        //var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts/\(self.account.accountId)")!)
//        request.httpMethod = "PUT"
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
//        request.cachePolicy = .reloadIgnoringLocalCacheData
        self.account.username = newUsername
        switch self.account.platform {
        case "Facebook":
            self.account.url = "https://www.facebook.com/\(newUsername)"
        case "Twitter":
            self.account.url = "https://www.twitter.com/\(newUsername)"
        case "Instagram":
            self.account.url = "https://www.instagram.com/\(newUsername)"
        case "Snapchat":
            self.account.url = "https://www.snapchat.com/add/\(newUsername)"
        case "LinkedIn":
            self.account.url = "https://www.linkedin.com/in/\(newUsername)"
        case "GooglePlus":
            self.account.url = "https://plus.google.com/\(newUsername)"
        case "Xbox":
            let usernameURL = newUsername.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            self.account.url = "https://account.xbox.com/en-us/Profile?GamerTag=\(usernameURL!)"
        case "PSN":
            let usernameURL = newUsername.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            self.account.url = "https://my.playstation.com/profile/\(usernameURL!)"
        case "Twitch":
            self.account.url  = "https://m.twitch.tv/\(newUsername)/profile"
        case "Custom":
            self.account.url  = "\(newUsername)"
        default:
            print("unknown app found: \(self.account.platform)")
            self.account.url = "\(newUsername)"
        }
        updateDisplayName()
//        let postString = "{\"displayName\": \"\(self.account.displayName)\", \"platform\": \"\(self.account.platform)\", \"url\": \"\(self.account.url)\", \"username\": \"\(newUsername)\"}"
//        print(request)
//        print(postString)
//        let task = URLSession.shared.dataTask(with: request, completionHandler: {
//            data, response, error in
//            if error != nil {
//                print("error=\(error)")
//                sema.signal()
//                return
//            } else {
//                print("---no error----")
//            }
//            //////////////////////// New stuff from Tom
//            do {
//                print("decoding")
//                //let decoder = JSONDecoder()
//                print("getting data")
//                let response = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, AnyObject>
//
//                //=======
//                print(response)
//                sema.signal();
//                //=======
//            } catch let err {
//                print("Err", err)
//                sema.signal(); // none found TODO: do something better than this shit.
//            }
//            print("Done")
//            /////////////////////////
//        })
//        task.resume()
//        sema.wait(timeout: DispatchTime.distantFuture)
//        loadAppsFromDB()
    }
    
    func deleteAccount(accountId: Int) {
        print("RIGHT HERE")
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts/\(accountId)")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        print(request)
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
                let response = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, AnyObject>
                //=======
                print(response)
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
        loadAppsFromDB()
    }
    
    func loadCustomRefreshContents() {
//        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
//
//        customView = refreshContents![0] as! UIView
//        customView.frame = self.view.bounds
//
//        for i in 0 ..< customView.subviews.count {
//            labelsArray.append(customView.viewWithTag(i + 1) as! UILabel)
//        }
//
//        refreshControl.addSubview(customView)
//
        if #available(iOS 10.0, *) {
            settingsAppsTableView.refreshControl = refreshControl
        } else {
            settingsAppsTableView.addSubview(refreshControl)
        }
        
    }
}
