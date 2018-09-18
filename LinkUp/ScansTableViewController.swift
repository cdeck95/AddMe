//
//  ScansTableViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/31/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ScansTableViewController: UITableViewController {

    //var scanIds: [String]!
    var pagedScans:PagedScans!
    var scans:[PagedProfile.Profile]!
    var credentialsManager = CredentialsManager.sharedInstance
    
    @IBOutlet var scansTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scans = []
        credentialsManager.createCredentialsProvider()

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
        return scans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScansTableViewCell", for: indexPath) as! ScansTableViewCell
        cell.profileName.text = pagedScans.scanned_profiles[indexPath.row].name
        cell.profileImage.sd_setImage(with: URL(string: pagedScans.scanned_profiles[indexPath.row].imageUrl ?? "https://images.pexels.com/photos/708440/pexels-photo-708440.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"), completed: nil)
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
        cell.profileImage.clipsToBounds = true;
        cell.profileDescription.text = pagedScans.scanned_profiles[indexPath.row].description
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
        //TODO - take scanIDs and load scan info from API
        scans = []
        scans = loadProfiles()
        pagedScans = PagedScans(scanned_profiles: scans)
        
        scansTableView.reloadData()
    }
    
    func loadProfiles() -> [PagedProfile.Profile]{
        //profiles = []
        var returnList:[PagedProfile.Profile] = []
        let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/scans")!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
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
                print(data)
                print(response)
                let JSONdata = try decoder.decode(PagedScans.self, from: data!)
                //=======
                for index in 0...JSONdata.scanned_profiles.count - 1 {
                    let profile = JSONdata.scanned_profiles[index]
                    print(profile)
                    returnList.append(profile)
                }
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
        return returnList
    }


}
