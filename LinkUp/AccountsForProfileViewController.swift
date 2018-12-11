//
//  AccountsForProfileViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/17/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import FCAlertView

class AccountsForProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FCAlertViewDelegate {

    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var appsTableView: UITableView!
    var profileID:Int!
    var accounts:[PagedAccounts.Accounts]!
    var allAccounts:[PagedAccounts.Accounts]!
    var profileImageImage: UIImage!
    var profileNameText: String!
    var profileDescriptionText: String!
    @IBOutlet var profileImage: ProfileImage!
    var profileImageUrl: String!
    var gradient: CAGradientLayer!
    var cells:[AppsTableViewCell]!
    var cognitoId:String!
    var profileName:String!
    var profileDescription:String!
    var flag:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer()
        self.profileImage.center = self.view.center
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true;
        cells = []
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("profile ID \(profileID)")
//        print("accounts in profile: \(accounts)")
 //       print("all accounts: \(allAccounts)")
        profileImage.sd_setImage(with: URL(string: profileImageUrl ?? "https://images.pexels.com/photos/708440/pexels-photo-708440.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"), completed: nil)    //   image = profileImageImage
//        profileName.text = profileNameText
//        profileDescription.text = profileDescriptionText
      //  appsTableView.layer.borderColor = Color.chill.value.cgColor
       // appsTableView.layer.borderWidth = 1
        appsTableView.layer.backgroundColor = UIColor.clear.cgColor
        appsTableView.layer.borderColor = UIColor.clear.cgColor
       
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
        func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }
    
        // There is just one row in every section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if(section == 0){
                return 2
            } else {
                return allAccounts.count
            }
        }

        // This is where the table cells on the main page are modeled from.
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.section == 0 {
                // Create an object of the dynamic cell “ProfileCell”
                if(indexPath.row == 0){
                    let cell:ProfileTableViewCell = appsTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
                    
                    cell.NameLabel.text = "Name"
                    cell.profileNameLabel.text = profileNameText
                    cell.layer.backgroundColor = UIColor.white.cgColor
                    return cell
                } else {
                    let cell:ProfileTableViewCell = appsTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
                    
                    cell.NameLabel.text = "Description"
                    cell.profileNameLabel.text = profileDescriptionText
                    cell.layer.backgroundColor = UIColor.white.cgColor
                    return cell
                }
               
            } else {
                // Create an object of the dynamic cell “AccountsCell”
                let cell:AppsTableViewCell = appsTableView.dequeueReusableCell(withIdentifier: "AccountsCell", for: indexPath) as! AppsTableViewCell
                print("Adding to table view now: \(cell)")
                if (!cellSwitches.contains(cell)) {
                    cellSwitches.append(cell)
                }
                cell.NameLabel.text = allAccounts[indexPath.row].displayName
                switch allAccounts[indexPath.row].platform {
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
                //cell.NameLabel.textColor = UIColor.white
                cell.layer.backgroundColor = UIColor.white.cgColor
                cell.url.text = "@\(allAccounts[indexPath.row].username)"
                cell.urlFull = allAccounts[indexPath.row].url
                cell.id = Int(allAccounts[indexPath.row].accountId)
                cell.userId = allAccounts[indexPath.row].userId
                cell.username = allAccounts[indexPath.row].username
                cell.platform = allAccounts[indexPath.row].platform
                cell.cognitoId = allAccounts[indexPath.row].cognitoId
                self.cognitoId = allAccounts[indexPath.row].cognitoId
                
                for account in accounts {
                    print(allAccounts[indexPath.row].accountId)
                    print(account.accountId)
                    if(allAccounts[indexPath.row].accountId == account.accountId){
                        cell.appSwitch.setOn(true, animated: true)
                        print("turning switch on")
                        break
                        //do nothing, the switch is already set
                    } else {
                        print("turning switch off")
                        cell.appSwitch.setOn(false, animated: true)
                    }
                }
                
                if(!cells.contains(cell)){
                    print("adding cell to array")
                    print(cell.appSwitch.isOn)
                    self.cells.append(cell)
                }
                return cell
            }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                let alert = FCAlertView()
                alert.delegate = self
                alert.colorScheme = Color.bondiBlue.value
                alert.addTextField(withPlaceholder: "Profile Name") { (text) in
                    self.appsTableView.deselectRow(at: indexPath, animated: true)
                    if(text) == "" {
                        print("field was blank")
                    } else {
                        self.profileName = text
                        self.flag = 1
                    }
                    print(text!)
                }
                alert.showAlert(inView: self,
                                withTitle: "Edit Profile",
                                withSubtitle: "Please update your profile name.",
                                withCustomImage: #imageLiteral(resourceName: "AddMeLogo-1"),
                                withDoneButtonTitle: "Update",
                                andButtons: ["Cancel"])
                return
            } else {
                let alert = FCAlertView()
                alert.delegate = self
                alert.colorScheme = Color.bondiBlue.value
                alert.addTextField(withPlaceholder: "Profile Description (i.e. Insta, Snap, Facebook") { (text) in
                    self.appsTableView.deselectRow(at: indexPath, animated: true)
                    if(text) == "" {
                        print("field was blank")
                    } else {
                        self.profileDescription = text
                        self.flag = 2
                    }
                    print(text!)
                }
                
                alert.showAlert(inView: self,
                                withTitle: "Edit Profile",
                                withSubtitle: "Please update your profile description.",
                                withCustomImage: #imageLiteral(resourceName: "AddMeLogo-1"),
                                withDoneButtonTitle: "Update",
                                andButtons: ["Cancel"])
                return
            }
            
        } else {
            //do nothing
        }
        
    }
    
    @IBAction func addAction(_ sender: Any) {
        
    }
    
    func fcAlertDoneButtonClicked(_ alertView: FCAlertView!) {
        print("done button clicked")
        if(self.flag == 1){
            self.profileNameText = self.profileName
        } else if (self.flag == 2){
             self.profileDescriptionText = self.profileDescription
        }
        self.appsTableView.reloadData()
    } 
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let gradientView = UIView(frame: self.view.bounds)
        gradient.frame = view.frame
        gradient.colors = [Color.glass.value.cgColor, Color.glass.value.cgColor]
        gradient.locations = [0.0, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        self.view.sendSubviewToBack(gradientView)
    }
    @IBAction func save(_ sender: Any) {
        //call API to update
        var accountsInProfile:[PagedAccounts.Accounts] = []
        print("in save function \(cells)")
        for cell in cells {
            if(cell.appSwitch.isOn){
                accountsInProfile.append(PagedAccounts.Accounts(accountId: cell.id!, userId: cell.userId, cognitoId: cell.cognitoId, displayName: cell.NameLabel.text!, platform: cell.platform, url: cell.urlFull, username: cell.username))
            }
        }
        print("Saving the profile with the following accounts: \(accountsInProfile)")

        let profileAccounts = accountsInProfile
        self.updateProfile(profileAccounts: profileAccounts, profileId: self.profileID)
        print("DISMISS THE DAMN VIEW PLEASE")
        if let resultController = storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as? ViewController {
            present(resultController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        if let resultController = storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as? ViewController {
            present(resultController, animated: true, completion: nil)
        }
        print("cancel hit")
       self.dismiss(animated: true, completion: nil) //self.navigationController?.popViewController(animated: true)

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        if(section == 0){
            vw.backgroundColor = .clear
            let textView = UITextView()
            textView.text = "Profile"
            textView.font = UIFont(name: "Trench", size: UIFont.labelFontSize)
            textView.textColor = .black
            textView.sizeToFit()
            textView.backgroundColor = .clear
            vw.addSubview(textView)
        } else {
            vw.backgroundColor = .clear
            let textView = UITextView()
            textView.text = "Connect Social Accounts"
            textView.font = UIFont(name: "Trench", size: UIFont.labelFontSize)
            textView.textColor = .black
            textView.sizeToFit()
            textView.backgroundColor = .clear
            vw.addSubview(textView)
        }
        
        return vw
    }
    
    func updateProfile(profileAccounts: [PagedAccounts.Accounts], profileId: Int){
        // Adds a users account to the DB.
        var success = true
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(self.cognitoId!)/profiles/\(profileId)")!)
        print("Request: \(request)")
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        //let accountData = try! JSONEncoder().encode(profile.accounts)
        var accountIds:[Int] = []
        for account in profileAccounts {
            accountIds.append(account.accountId)
        }
        let json = """
        {
            "accounts": \(accountIds),
            "name": "\(self.profileNameText!)",
            "description": "\(self.profileDescriptionText!)",
            "imageUrl": "\(self.profileImageUrl ?? "https://images.pexels.com/photos/708440/pexels-photo-708440.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260")"
        }
        """.data(using: .utf8)!
        print("request body: \(String(data: json, encoding: .utf8)!)")
       
//        let jsonData = try! JSONEncoder().encode(profile)
//        print("Custom encode: \n \(jsonData)")
//        let jsonString = String(data: jsonData, encoding: .utf8)!
//        print(jsonString)
        //print(postString)
        request.httpBody = json//jsonString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                success = false
                sema.signal()
                return
            }
            success = true
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            print("Response \(responseOne!)")
            sema.signal()
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        if(success){
            let alert = FCAlertView()
            alert.delegate = self
            alert.colorScheme = Color.bondiBlue.value
            alert.showAlert(inView: self,
                            withTitle: "Success!",
                            withSubtitle: "Your profile has been updated.",
                            withCustomImage: #imageLiteral(resourceName: "fb-icon"),
                            withDoneButtonTitle: "Okay",
                            andButtons: [""])
        } else{
            let alert = FCAlertView()
            alert.delegate = self
            alert.colorScheme = Color.bondiBlue.value
            alert.showAlert(inView: self,
                            withTitle: "Oops!",
                            withSubtitle: "Something went wrong. Try again. If this keeps happening, contact support.",
                            withCustomImage: #imageLiteral(resourceName: "fb-icon"),
                            withDoneButtonTitle: "Okay",
                            andButtons: [""])

        }
    }
}

extension PagedProfile.Profile {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //try container.encode(profileId, forKey: .profileId)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        //try container.encode(cognitoId, forKey: .cognitoId)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(accounts, forKey: .accounts)
    }
}

extension PagedAccounts.Accounts {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountId = try container.decode(Int.self, forKey: .accountId)
        userId = try container.decode(Int.self, forKey: .userId)
        displayName = try container.decode(String.self, forKey: .displayName)
        username = try container.decode(String.self, forKey: .username)
        url = try container.decode(String.self, forKey: .url)
        platform = try container.decode(String.self, forKey: .platform)
        cognitoId  = try container.decode(String.self, forKey: .cognitoId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //try container.encode(profileId, forKey: .profileId)
        try container.encode(accountId, forKey: .accountId)
    }
}
