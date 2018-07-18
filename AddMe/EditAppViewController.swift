//
//  EditAppViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 4/21/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class EditAppViewController: UIViewController, UITextFieldDelegate {

    var AppID:Int!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var platform: UITextField!
    var credentialsManager = CredentialsManager.sharedInstance
    var lines:[String]!
    
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
        let accounts: [[String: String]]
    }
    
    var JsonApps = [JsonApp]()
    ////////////////////////////// END OF JSON ///////////////////////////////////
    
    override func viewDidAppear(_ animated: Bool) {
        func loadAppsFromDB(){
            print("EditAppViewController viewDidAppear()")
            var returnList: [Apps] = []
            let idString = self.credentialsManager.identityID!
            print(idString)
            let sema = DispatchSemaphore(value: 0);
            var request = URLRequest(url:URL(string: "https://api.tc2pro.com/getUserByID")!)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
            
            let postString = "{\"user\": {\"cognitoId\": \"\(idString)\"}}"
            print(postString)
            request.httpBody = postString.data(using: String.Encoding.utf8)
            print(request.httpBody)
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
                    for index in 0...JSONdata.accounts.count - 1 {
                        let listOfAccountInfo = JSONdata.accounts[index]
                        let dispName = listOfAccountInfo["displayName"]!
                        let pform = listOfAccountInfo["platform"]!
                        let url = listOfAccountInfo["url"]!
                        let cognitoId = listOfAccountInfo["cognitoId"]!
                        print(dispName)
                        print(pform)
                        print(url)
                        print(cognitoId)
                        
                        self.displayName.text = dispName
                        self.platform.text = pform
                        self.userName.text = url
                    }
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
        }
    }
    
    func oldViewDidAppear(_ animated: Bool) {
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
        case "GooglePlus":
            url = "http://plus.google.com/\(newUserName)"
        default:
            print("unknown app found: \(newPlatform)")
        }
        print(newPlatform)
        print(newDisplayName)
        print(newUserName)
        print(url)
        
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users")!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        let postString = "{\"user\": {\"displayName\": \"\(newDisplayName)\", \"cognitoId\": \"\(newUserName)\", \"platform\": \"\(newPlatform)\", \"url\": \"\(url)\"}}"
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
    }
    
    func oldSaveApp(){
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
        case "GooglePlus":
            url = "http://plus.google.com/\(newUserName)"
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
        let newUserName = userName.text!
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        let postString = "{\"user\": {\"cognitoId\": \"\(newUserName)\"}}"
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
    }
    
    func oldDeleteApp(){
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
