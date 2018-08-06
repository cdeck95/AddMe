//
//  EditAppViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 4/21/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class EditAppViewController: UIViewController, UITextFieldDelegate {

    var AppID:String?
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var platform: UITextField!
    var credentialsManager = CredentialsManager.sharedInstance
    var lines:[String]!
    var identityID: String!
    
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayName.delegate = self
        self.userName.delegate = self
        platform.isUserInteractionEnabled = false
        credentialsManager.createCredentialsProvider()
        displayName.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        userName.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
    }
    
    ////////////////////////////// BEGINNING OF JSON ///////////////////////////////////
    
    // TomMiller 2018/06/27 - Added struct to interact with JSON
    struct JsonApp: Decodable {
        //["{\"accounts\":[{\"cognitoId\":\"us-east-1:bafa67f1-8631-4c47-966d-f9f069b2107c\",\"displayName\":\"tomTweets\",\"platform\":\"Twitter\",\"url\":\"http://www.twitter.com/TomsTwitter\"}]}", ""]
        let account: [String: String]
    }
    
    var JsonApps = [JsonApp]()
    ////////////////////////////// END OF JSON ///////////////////////////////////
    
    override func viewDidAppear(_ animated: Bool) {
        identityID = credentialsManager.identityID!
        loadAppFromDB()
    }
    
    func loadAppFromDB(){
        print("EditAppViewController viewDidAppear()")
        let returnList: [Apps] = []
        //let idString = self.credentialsManager.identityID!
        print(identityID!)
        let sema = DispatchSemaphore(value: 0);
        let url = URL(string: "https://api.tc2pro.com/users/\(identityID!)/accounts/\(AppID!)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        print(request)
        //let postString = "{\"user\": {\"cognitoId\": \"\(idString)\"}}"
        //print(postString)
        //request.httpBody = postString.data(using: String.Encoding.utf8)
        //print(request.httpBody)
        var dispName: String!
        var pform: String!
        var cognitoId: String!
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
                print("decoding in edit")
                let decoder = JSONDecoder()
                print("getting data in edit")
                let JSONdata = try decoder.decode(JsonApp.self, from: data!)
                //=======
                let listOfAccountInfo = JSONdata.account
                dispName = listOfAccountInfo["displayName"]!
                pform = listOfAccountInfo["platform"]!
                cognitoId = listOfAccountInfo["cognitoId"]!
                print(dispName)
                print(pform)
                print(cognitoId)
                apps = returnList
                sema.signal();
                //=======
            } catch let err {
                print("Err", err)
                apps = returnList
                sema.signal(); // none found TODO: do something better than this shit.
            }
            print("Done")
            /////////////////////////
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        
        self.displayName.text = dispName
        self.platform.text = pform
        self.userName.text = ""
        
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
        case "GooglePlus":
            url = "http://plus.google.com/\(newUserName)"
        case "Xbox":
            let usernameURL = newUserName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            url = "https://account.xbox.com/en-us/Profile?GamerTag=\(usernameURL!)"
        case "PSN":
            let usernameURL = newUserName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            url = "https://my.playstation.com/profile/\(usernameURL!)"
        case "Twitch":
            url = "https://m.twitch.tv/\(newUserName)/profile"
        case "Custom":
            url = "\(newUserName)"
        default:
            print("unknown app found: \(newPlatform)")
        }
        print(newPlatform)
        print(newDisplayName)
        print(url)
        
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(identityID!)/accounts/\(AppID!)")!)
        print(request)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        let postString = "{\"displayName\": \"\(newDisplayName)\",\"platform\": \"\(newPlatform)\", \"url\": \"\(url)\"}"
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
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(identityID!)/accounts/\(AppID!)")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
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
    
    //hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //hide keyboard when user hits return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //self.view.endEditing(true)
        return true
    }
    
    
    
    @objc func textFieldDidChange(textField: UITextField) {
        if displayName.text == "" || userName.text == "" {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }

}
