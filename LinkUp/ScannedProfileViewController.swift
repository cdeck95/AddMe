//
//  ScannedProfileViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/20/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ScannedProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var allApps: [Accounts]!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var accountsForProfileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(allApps)
        self.profileImage.center = self.view.center
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allApps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an object of the dynamic cell “AccountsCell”
        let cell:ScannedTableViewCell = accountsForProfileTableView.dequeueReusableCell(withIdentifier: "ScannedProfileCell", for: indexPath) as! ScannedTableViewCell
        cell.url.text = "@test"
        switch allApps[indexPath.row].platform {
        case "Facebook":
            cell.appIcon.image = UIImage(named: "fb-icon")
        case "Twitter":
            cell.appIcon.image = UIImage(named: "twitter_icon")
        case "Instagram":
            cell.appIcon.image = UIImage(named: "Instagram_icon")
        case "Snapchat":
            cell.appIcon.image = UIImage(named: "snapchat_icon")
        case "GooglePlus":
            cell.appIcon.image = UIImage(named: "google_plus_icon")
        case "LinkedIn":
            cell.appIcon.image = UIImage(named: "linked_in_logo")
        case "Xbox":
            cell.appIcon.image = UIImage(named: "xbox")
        case "PSN":
            cell.appIcon.image = UIImage(named: "play-station")
        case "Twitch":
            cell.appIcon.image = UIImage(named: "twitch")
        case "Custom":
            cell.appIcon.image = UIImage(named: "custom")
        default:
            cell.appIcon.image = UIImage(named: "AppIcon")
        }
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
