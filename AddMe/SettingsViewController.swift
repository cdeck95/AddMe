//
//  SettingsViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/25/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSCognito

class SettingsViewController: UIViewController {

    var sideMenuViewController = SideMenuViewController()
    var isMenuOpened:Bool = false
    var dataset: AWSCognitoDataset!
    var credentialsManager = CredentialsManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuViewController = storyboard!.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
        sideMenuViewController.view.frame = UIScreen.main.bounds
        let syncClient = AWSCognito.default()
        dataset = syncClient.openOrCreateDataset("AddMeDataSet\(credentialsManager.identityID)")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
       self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
        print("Loading list of installed apps in Settings.")
        // This is only here as a reference to know how to access the apps the user has.
        for index in 0...cellSwitches.count - 1{
            var isSelectedForQRCode = cellSwitches[index].appSwitch.isOn
            var app = cellSwitches[index].NameLabel.text! + ""
            print(app)
            print(isSelectedForQRCode)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuClicked(_ sender: Any) {
        if(isMenuOpened){
            isMenuOpened = false
            sideMenuViewController.willMove(toParentViewController: nil)
            sideMenuViewController.view.removeFromSuperview()
            sideMenuViewController.removeFromParentViewController()
        }
        else{
            isMenuOpened = true
            self.addChildViewController(sideMenuViewController)
            self.view.addSubview(sideMenuViewController.view)
            sideMenuViewController.didMove(toParentViewController: self)
        }
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
    
    // Going to connect this to a button on the Settings view.
    // Will delete all apps that the user has selected.
    func deleteSelectedApps()
    {
        // Planning on having a tableview with the custom cells on the screen.
        // It will be populated from the cellSwitches array.
        // The custom cells will have a toggle switch, a label for the name (facebook,etc.)
        // and a button to launch another view for editting the info about that selected cell.
    }
    
    // TODO: Probably should add a Confirm Delete? button.
    @IBAction func deleteApps(_ sender: Any) {
        dataset.removeObject(forKey: "apps")
        cellSwitches = []
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
