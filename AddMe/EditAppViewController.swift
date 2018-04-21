//
//  EditAppViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 4/21/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class EditAppViewController: UIViewController {

    var AppID:Int!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var platform: UITextField!
    var credentialsManager = CredentialsManager.sharedInstance
    var lines:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        platform.isUserInteractionEnabled = false
        credentialsManager.createCredentialsProvider()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("in view did appear for edit app")
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/getUserInfoById.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(AppID!)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                sema.signal()
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            self.lines = responseOne!.components(separatedBy: "\n")
            print(self.lines)
            sema.signal()
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        displayName.text = lines[1]
        platform.text = lines[2]
        let trimUsername = lines[3]
        let array = trimUsername.components(separatedBy: "/")
        let finalUserName = array.last
        userName.text = finalUserName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveApp(_ sender: Any) {
        let newDisplayName = displayName.text!
        let newUserName = userName.text!
        let newPlatform = platform.text!
        let identityID = credentialsManager.identityID!
        var url:String = ""
        
        switch newPlatform {
            case "Facebook":
                url = "http://facebook.com/\(newUserName)"
            case "Twitter":
                url = "http://www.twitter.com/\(newUserName)"
            case "Instagram":
                url = "http://www.instagram.com/\(newUserName)"
            case "Snapchat":
                url = "http://www.snapchat.com/add/\(newUserName)"
            case "LinkedIn":
                url = "http://www.linkedin.com/in/\(newUserName)"
            default:
                print("unknown app found: \(newPlatform)")
            }
        print(newPlatform)
        print(newDisplayName)
        print(newUserName)
        print(url)
        
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/setUserInfo.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(identityID)&b=\(newDisplayName)&c=\(newPlatform)&d=\(url)&e=\(AppID!)"
        print(postString)
        request.httpBody = postString.data(using: String.Encoding.utf8)

        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }

            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            print(responseOne!)
        })
        task.resume()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteApp(_ sender: Any) {
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/deleteUserById.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(AppID!)"
        print(postString)
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            print(responseOne!)
        })
        task.resume()
        
        self.dismiss(animated: true, completion: nil)
    }
    

}
