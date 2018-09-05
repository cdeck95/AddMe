//
//  AccountsForProfileViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/17/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import FCAlertView

class AccountsForProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HalfModalPresentable, FCAlertViewDelegate {

    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var appsTableView: UITableView!
    var profileID:String!
    var accounts:[Accounts]!
    var allAccounts:[Accounts]!
    var profileImageImage: UIImage!
    var profileNameText: String!
    var profileDescriptionText: String!
    @IBOutlet var profileImage: ProfileImage!
    var gradient: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer()
        self.profileImage.center = self.view.center
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true;
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("profile ID \(profileID)")
//        print("accounts in profile: \(accounts)")
 //       print("all accounts: \(allAccounts)")
        profileImage.image = profileImageImage
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
                cell.id = Int(allAccounts[indexPath.row].accountId)
                
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
                
                //print(indexPath.row)
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
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let gradientView = UIView(frame: self.view.bounds)
        gradient.frame = view.frame
        gradient.colors = [Color.glass.value.cgColor, Color.glass.value.cgColor]
        gradient.locations = [0.0, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        self.view.sendSubview(toBack: gradientView)
    }
    @IBAction func save(_ sender: Any) {
        //call API to update
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
}
