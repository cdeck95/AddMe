//
//  ScansTableViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/31/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ScansTableViewController: UITableViewController {

    var scanIds: [String]!
    var fakeScanData:[Scan] = []
    
    @IBOutlet var scansTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        loadScans()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fakeScanData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScansTableViewCell", for: indexPath) as! ScansTableViewCell
        cell.profileName.text = fakeScanData[indexPath.row].name
        cell.profileImage.image = fakeScanData[indexPath.row].profileImage
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
        cell.profileImage.clipsToBounds = true;
        cell.profileDescription.text = fakeScanData[indexPath.row].descriptionLabel
        cell.profileDescription.sizeToFit()

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        if(section == 0){
            vw.backgroundColor = .clear
            let textView = UITextView()
            textView.text = "Previous Scans"
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

    
    //Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        //Return false if you do not want the item to be re-orderable.
        return false
    }
    
    func loadScans(){
        //TODO - load scan IDs from API
        scanIds = ["1","2","3"]
        //TODO - take scanIDs and load scan info from API
        let dict1 = ["profileID":"1", "name": "Dan Boehmke", "id": "1", "descriptionLabel":"All accounts"] as NSDictionary
        let scan = Scan(dictionary: dict1, imageIn: UIImage(named: "dance-floor-of-night-club.png")!)
        fakeScanData.append(scan)
        let dict2 = ["profileID":"2", "name": "Tom Miller", "id": "2", "descriptionLabel":"Xbox, PSN, Twitch"] as NSDictionary
        let scan2 = Scan(dictionary: dict2, imageIn: UIImage(named: "dance-floor-of-night-club.png")!)
        fakeScanData.append(scan2)
        let dict3 = ["profileID":"3", "name": "Chris Deck", "id": "3", "descriptionLabel":"Facebook, Instagram, Twitter, Snachat"] as NSDictionary
        let scan3 = Scan(dictionary: dict3, imageIn: UIImage(named: "dance-floor-of-night-club.png")!)
        fakeScanData.append(scan3)
        let dict4 = ["profileID":"4", "name": "Chris Porch", "id": "4", "descriptionLabel":"Snapchat, Insta"] as NSDictionary
        let scan4 = Scan(dictionary: dict4, imageIn: UIImage(named: "dance-floor-of-night-club.png")!)
        fakeScanData.append(scan4)
        scansTableView.reloadData()
    }
 


}
