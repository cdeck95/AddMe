//
//  ChooseSettingsTableViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 4/21/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ChooseSettingsTableViewController: UITableViewController {

    var options:[String] = ["Edit/Remove Apps", "Edit Personal Info"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! ChooseSettingsTableViewCell
        cell.onButtonTapped = {
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.navigationController!.show(VC1, sender: cell)
        }
        cell.settingName.text = options[indexPath.row]
        print(cell.settingName.text)
        return cell
    }

    
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return false
//    }

}
