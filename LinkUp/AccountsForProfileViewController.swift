//
//  AccountsForProfileViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/17/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class AccountsForProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HalfModalPresentable {

    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var appsTableView: UITableView!
    var profileID:String!
    var accounts:[Apps]!
    var profileImageImage: UIImage!
    var profileNameText: String!
    var profileDescriptionText: String!
    @IBOutlet var profileImage: ProfileImage!
    @IBOutlet var profileName: UITextField!
    @IBOutlet var profileDescription: UITextField!
    var gradient: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("profile ID \(profileID)")
        print("accounts: \(accounts)")
        profileImage.image = profileImageImage
        profileName.text = profileNameText
        profileDescription.text = profileDescriptionText
        appsTableView.layer.borderColor = Color.chill.value.cgColor
        appsTableView.layer.borderWidth = 1
        createGradientLayer()
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
            return 1
        }
    
        // There is just one row in every section
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return accounts.count
        }

        // This is where the table cells on the main page are modeled from.
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Create an object of the dynamic cell “PlainCell”
            let cell:AppsTableViewCell = appsTableView.dequeueReusableCell(withIdentifier: "AccountsCell", for: indexPath) as! AppsTableViewCell
            print("Adding to table view now: \(cell)")
            if (!cellSwitches.contains(cell)) {
                cellSwitches.append(cell)
            }
            cell.NameLabel.text = accounts[indexPath.section]._displayName
            switch accounts[indexPath.section]._platform {
            case "Facebook"?:
                cell.appImage.image = UIImage(named: "fb-icon")
            case "Twitter"?:
                cell.appImage.image = UIImage(named: "twitter_icon")
            case "Instagram"?:
                cell.appImage.image = UIImage(named: "Instagram_icon")
            case "Snapchat"?:
                cell.appImage.image = UIImage(named: "snapchat_icon")
            case "GooglePlus"?:
                cell.appImage.image = UIImage(named: "google_plus_icon")
            case "LinkedIn"?:
                cell.appImage.image = UIImage(named: "linked_in_logo")
            case "Xbox"?:
                cell.appImage.image = UIImage(named: "xbox")
            case "PSN"?:
                cell.appImage.image = UIImage(named: "play-station")
            case "Twitch"?:
                cell.appImage.image = UIImage(named: "twitch")
            case "Custom"?:
                cell.appImage.image = UIImage(named: "custom")
            default:
                cell.appImage.image = UIImage(named: "AppIcon")
            }
            cell.NameLabel.textColor = UIColor.white
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.url.text = accounts[indexPath.section]._uRL!
            cell.id = Int(accounts[indexPath.section]._appId!)
            //print(indexPath.row)
            return cell
    }
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let gradientView = UIView(frame: self.view.bounds)
        gradient.frame = view.frame
        gradient.colors = [UIColor(red: 61/255, green: 218/255, blue: 215/255, alpha: 1).cgColor, UIColor(red: 42/255, green: 147/255, blue: 213/255, alpha: 1).cgColor, UIColor(red: 19/255, green: 85/255, blue: 137/255, alpha: 1).cgColor]
        gradient.locations = [0.0, 0.5, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        self.view.sendSubview(toBack: gradientView)
    }

}
