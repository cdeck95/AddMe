//
//  AccountsForProfileViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/17/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class AccountsForProfileViewController: UIViewController, HalfModalPresentable, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var appsTableView: UITableView!
    var profileID:String!
    var accounts:[Apps]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("profile ID \(profileID)")
        print("accounts: \(accounts)")
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
            cell.NameLabel.text = apps[indexPath.section]._displayName
            switch apps[indexPath.section]._platform {
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
            //cell.NameLabel.textColor = UIColor.white
            //cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.url.text = apps[indexPath.section]._uRL!
            cell.id = Int(apps[indexPath.section]._appId!)
            //print(indexPath.row)
            return cell
    }

}
