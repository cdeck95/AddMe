//
//  ScansTableViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/31/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import FCAlertView
import Sheeeeeeeeet

class ScansTableViewController: UITableViewController, FCAlertViewDelegate {

    //var scanIds: [String]!
   // var pagedScans:PagedScans!
    var scans:[PagedScans.Scan]!
    var credentialsManager = CredentialsManager.sharedInstance
    var gradient:CAGradientLayer!
    
    @IBOutlet var scansTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scans = []
        loadScans()
        print(scans)
        credentialsManager.createCredentialsProvider()
       // createGradientLayer()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        let refreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:
                #selector(ScansTableViewController.handleRefresh(_:)),
                                     for: UIControlEvents.valueChanged)
            refreshControl.tintColor = Color.coral.value
            
            return refreshControl
        }()
        self.tableView.addSubview(refreshControl)
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadScans()
        refreshControl.endRefreshing()
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
        cell.profileName.text = scans[indexPath.row].name
        cell.profileImage.sd_setImage(with: URL(string: scans[indexPath.row].imageUrl ?? "https://images.pexels.com/photos/708440/pexels-photo-708440.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"), completed: nil)
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
        cell.profileImage.clipsToBounds = true;
        cell.profileDescription.text = scans[indexPath.row].description
        cell.profileDescription.numberOfLines = 0
        cell.profileDescription.sizeToFit()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("will show options")
        let actionSheet = createStandardActionSheet(indexPath: indexPath)
        actionSheet.present(in: self, from: self.view)
    }
    
   

    func createStandardActionSheet(indexPath: IndexPath) -> ActionSheet {
        let title = ActionSheetTitle(title: "Select an option")
        let item1 = ActionSheetItem(title: "View Profile", value: "1", image: UIImage(named: "baseline_pageview_black_18pt"))
        let deleteButton = ActionSheetDangerButton(title: "Delete Scan")
        let button = ActionSheetOkButton(title: "Cancel")
        return ActionSheet(items: [title, item1, deleteButton, button]) { _, item in
            
            guard let value = item.value as? String else {
                if item is ActionSheetDangerButton {
                    self.deleteScan(profileId: self.scans[indexPath.row].profileId)
                }
                return
            }
            
            if value == "1" {
                let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "SingleProfileViewController") as! SingleProfileViewController
               // self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                let profile = self.loadFullProfile(profileId: self.scans[indexPath.row].profileId, idString: self.scans[indexPath.row].cognitoId)
                modalVC.allAccounts = profile.accounts
                modalVC.profile = profile
                modalVC.modalTransitionStyle = .crossDissolve
               // modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
                self.navigationController?.pushViewController(modalVC, animated: true)
            }
        }
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
        vw.backgroundColor = .clear
        let textView = UITextView()
        textView.text = "Previous Scans"
        textView.font = UIFont(name: "Trench", size: UIFont.labelFontSize)
        textView.textColor = .black
        textView.sizeToFit()
        textView.backgroundColor = .clear
        vw.addSubview(textView)
        
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
        print("have scans")
       // pagedScans = PagedScans(scanned_profiles: scans)
        
        scansTableView.reloadData()
    }
    
    func loadProfiles() -> [PagedScans.Scan]{
        //profiles = []
        var returnList:[PagedScans.Scan] = []
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
                let decoder = JSONDecoder()
                let parser = APIMessageParser(received: response.debugDescription, parent: self.inputViewController!)
                let JSONdata = try decoder.decode(PagedScans.self, from: data!)
                //=======
                if(JSONdata.scanned_profiles.count > 0){
                    for index in 0...JSONdata.scanned_profiles.count - 1 {
                        let profile = JSONdata.scanned_profiles[index]
                        print(profile)
                        returnList.append(profile)
                    }
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
    
    func loadFullProfile(profileId: Int, idString: String) -> SingleProfile.Profile{
        //profiles = []
        var profile:SingleProfile.Profile!
       // let idString = self.credentialsManager.identityID!
        print(idString)
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/profiles/\(profileId)")!)
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
                let singleProfile = try decoder.decode(SingleProfile.self, from: data!)
                profile = singleProfile.profile
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
        return profile
    }

    func deleteScan(profileId: Int){
        // Adds a users account to the DB.
        var success = true
        let sema = DispatchSemaphore(value: 0);
        let identityId = self.credentialsManager.identityID!
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(identityId)/scans/\(profileId)")!)
        print("Request: \(request)")
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
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
                            withTitle: "Success",
                            withSubtitle: "The scan was successfully removed from your history.",
                            withCustomImage: #imageLiteral(resourceName: "AddMeLogo-1"),
                            withDoneButtonTitle: "Got it!",
                            andButtons: [])
            loadProfiles()
        } else{
            let alert = FCAlertView()
            alert.delegate = self
            alert.colorScheme = Color.bondiBlue.value
            
            alert.showAlert(inView: self,
                            withTitle: "Oops!",
                            withSubtitle: "Something went wrong. If this keeps happening, please contact support.",
                            withCustomImage: #imageLiteral(resourceName: "AddMeLogo-1"),
                            withDoneButtonTitle: "Got it!",
                            andButtons: [])
            loadProfiles()
        }
    }
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let gradientView = UIView(frame: self.view.bounds)
        gradient.frame = self.view.frame
        //        gradient.colors = [UIColor(red: 61/255, green: 218/255, blue: 215/255, alpha: 1).cgColor, UIColor(red: 42/255, green: 147/255, blue: 213/255, alpha: 1).cgColor, UIColor(red: 19/255, green: 85/255, blue: 137/255, alpha: 1).cgColor]
        //        gradient.locations = [0.0, 0.5, 1.0]
        //        gradient.colors = [Color.glass.value.cgColor, Color.coral.value.cgColor, Color.bondiBlue.value.cgColor, Color.marina.value.cgColor]
        //        gradient.locations = [0.0, 0.33, 0.66, 1.0]
        gradient.colors = [Color.chill.value.cgColor, Color.chill.value.cgColor]
        gradient.locations = [0.0, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        self.view.sendSubview(toBack: gradientView)
    }

}
