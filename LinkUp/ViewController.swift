//
//  ViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/16/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthUI
import AWSUserPoolsSignIn
import AWSFacebookSignIn
import AWSGoogleSignIn
import AWSCore
import AWSCognito
import AWSCognitoIdentityProviderASF
import GoogleSignIn
import FacebookCore
import GoogleMobileAds
import FCAlertView
import Sheeeeeeeeet
import SDWebImage

var cellSwitches: [AppsTableViewCell] = []
var apps: [PagedAccounts.Accounts] = []

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, FCAlertViewDelegate, UIScrollViewDelegate {

    var FCAction: String = ""
    var profiles: [PagedProfile.Profile]!
    var bannerView: DFPBannerView!
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    var identityProvider:String!
    var credentialsManager = CredentialsManager.sharedInstance
    var datasetManager = Dataset.sharedInstance
    var dataset: AWSCognitoDataset!
    private let refreshControl = UIRefreshControl()
    var newProfileName: String!
    var newProfileDesc: String!
    
    @IBOutlet var uploadImageButton: UIBarButtonItem!
    var token: String!
    let imagePicker = UIImagePickerController()
    var gradient: CAGradientLayer!
    let cellSpacingHeight: CGFloat = 15
    var isCellTapped = false
    var selectedSectionIndex = -1
    var customView: UIView!
    var labelsArray: Array<UILabel> = []
    var isDarkModeEnabled = false
    private var themeColor = UIColor.white
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var profileImage: ProfileImage!
    @IBOutlet var pageControl: UIPageControl!
    
    let collectionMargin = CGFloat(16)
    let itemSpacing = CGFloat(10)
    let itemHeight = CGFloat(260)
    
    var itemWidth = CGFloat(0)
    var currentItem = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCustomRefreshContents()
        // Configure Refresh Control
        profiles = []
        refreshControl.addTarget(self, action: #selector(refreshAppData(_:)), for: .valueChanged)
        imagePicker.delegate = self
        createGradientLayer()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "/6499/example/banner"
        bannerView.rootViewController = self
        bannerView.load(DFPRequest())
        
        nameLabel.center = self.view.center
        collectionView.center = self.view.center
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //collectionView.scrollViewDelegate = self
        itemWidth =  UIScreen.main.bounds.width - collectionMargin * 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        presentAuthUIViewController()
        refreshAppData(self)
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
    
    func presentAuthUIViewController() {
        let config = AWSAuthUIConfiguration()
        config.enableUserPoolsUI = true
        config.addSignInButtonView(class: AWSFacebookSignInButton.self)
        config.addSignInButtonView(class: AWSGoogleSignInButton.self)
        config.logoImage = UIImage(named: "LogoTransparent")
        config.backgroundColor = UIColor.white
        config.font = UIFont (name: "Helvetica Neue", size: 14)
        config.canCancel = true
        
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            AWSAuthUIViewController
                .presentViewController(with: self.navigationController!,
                                       configuration: config,
                                       completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                        if error != nil {
                                            print("Error occurred: \(String(describing: error))")
                                        } else {
                                            // Sign in successful.
                                        }
                })
        }
        else {
            self.navigationController?.popToRootViewController(animated: true)// Initialize the Cognito Sync client
            credentialsManager.createCredentialsProvider()
            //credentialsManager.credentialsProvider.getIdentityId()
            credentialsManager.credentialsProvider.identityProvider.logins().continueWith { (task: AWSTask!) -> AnyObject? in
                
                if (task.error != nil) {
                    print("ERROR: Unable to get logins. Description: \(task.error!)")
                    
                } else {
                    if task.result != nil{
                    }
                    self.credentialsManager.credentialsProvider.getIdentityId().continueWith { (task: AWSTask!) -> AnyObject? in
                        
                        if (task.error != nil) {
                            print("ERROR: Unable to get ID. Error description: \(task.error!)")
                            
                        } else {
                            print("Signed in user with the following ID:")
                            let id = task.result! as? String
                            self.credentialsManager.setIdentityID(id: id!)
                            print(self.credentialsManager.identityID)
                            self.datasetManager.createDataset()
                            self.loadProfiles()
                            if AWSFacebookSignInProvider.sharedInstance().isLoggedIn {
                                print("facebook sign in confirmed")
                                self.navigationItem.leftBarButtonItem = nil
                                let params: String = "name,email,picture"
                                self.getFBUserInfo(params: params, dataset: self.datasetManager.dataset)
                            } else {
                                self.profileImage.image = UIImage(named: "LogoTransparent")
                                self.profileImage.center = self.view.center
                                //self.navigationItem.leftBarButtonItem = self.uploadImageButton
                                //query the db for an image
                            }
                        }
                        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
                        self.profileImage.clipsToBounds = true;
                        return nil
                    }
                    
                    return nil
                }
                return nil
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func getFBUserInfo(params: String, dataset: AWSCognitoDataset) {
        let request = GraphRequest(graphPath: "me", parameters: ["fields":params], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
                case .success(let value):
                    print(value.dictionaryValue ?? "-1")
                    let userID = value.dictionaryValue?["id"] as! String
                    dataset.setString(userID, forKey: "userID")
                    let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(userID)/picture?type=large")
                    if let data = NSData(contentsOf: facebookProfileUrl!) {
                        self.profileImage.image = UIImage(data: data as Data)
                        
                    }
                dataset.setString(value.dictionaryValue?["id"] as? String, forKey: "Facebook")
                self.nameLabel.text = value.dictionaryValue?["name"] as? String
            case .failed(let error):
                print(error)
            }
        }
    }
    
    // Goes through the list of table cells that contain the switches for which apps
    // to use in the QR Code being made. It checks their label and UISwitch.
    // If the switch is "On" then it will be included in the QR codes creation.
    @IBAction func createQRCode(_ sender: Any) {
       // loadApps()
        var jsonStringAsArray = "{\n"
        if(cellSwitches.count > 0){
            for index in 0...cellSwitches.count - 1{
                let isSelectedForQRCode = cellSwitches[index].appSwitch.isOn
                let appID = cellSwitches[index].id
                print(appID)
                print(isSelectedForQRCode)
                if (isSelectedForQRCode){
                    let app = apps[index]
                    jsonStringAsArray += "\"\(app.displayName)\": \"\(app.url)\",\n"
                } else {
                    print("app not found to make QR code")
                }
            }
        } else {
            print("no apps - casnnot create code")
        }
        jsonStringAsArray += "}"
        let result = jsonStringAsArray.replacingLastOccurrenceOfString(",",
                                                              with: "")
        print(result)
        if(datasetManager.dataset != nil){
            datasetManager.dataset.setString(result, forKey: "jsonStringAsArray")
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        //Convert string to data
        let stringData = string.data(using: String.Encoding.utf8)
        
        //Generate CIImage
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(stringData, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciImage = filter?.outputImage else { return nil }
        
        //Scale image to proper size
        // let scale = CGFloat(size) / ciImage.extent.size.width
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        //Convert to CGImage
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return nil }
        
        //Finally return the UIImage
        return UIImage(cgImage: cgImage)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
       
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
    }

    @IBAction func uploadImage(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let qrcodeImg = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            self.profileImage.image = qrcodeImg
            //send image to DB
        }
        else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let gradientView = UIView(frame: self.view.bounds)
        gradient.frame = view.frame
//        gradient.colors = [UIColor(red: 61/255, green: 218/255, blue: 215/255, alpha: 1).cgColor, UIColor(red: 42/255, green: 147/255, blue: 213/255, alpha: 1).cgColor, UIColor(red: 19/255, green: 85/255, blue: 137/255, alpha: 1).cgColor]
//        gradient.locations = [0.0, 0.5, 1.0]
//        gradient.colors = [Color.glass.value.cgColor, Color.coral.value.cgColor, Color.bondiBlue.value.cgColor, Color.marina.value.cgColor]
//        gradient.locations = [0.0, 0.33, 0.66, 1.0]
        gradient.colors = [Color.chill.value.cgColor, Color.chill.value.cgColor]
        gradient.locations = [0.0, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        self.view.sendSubviewToBack(gradientView)
    }
    
    func addBannerViewToView(_ bannerView: DFPBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            let count = profiles.count + 1
            let count = profiles.count
            pageControl.numberOfPages = count
            print(profiles)
            print("--------------------")
//            return profiles.count + 1
            return profiles.count
        }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
        cell.layer.backgroundColor = UIColor.white.cgColor
       // cell.nameLabel.textColor = Color.glass.value
       // cell.descLabel.textColor = Color.glass.value
        if indexPath.item == profiles.count {
//            cell.profileImage.image = UIImage(named: "add_more.png")
//            //cell.profileImage.frame = cell.bounds
//            cell.nameLabel.text = "Add a Profile"
//            cell.descLabel.isHidden = true
//            cell.openButton.setImage(UIImage(named: "ic_add_circle"), for: .normal)
        } else {
            print(profiles[indexPath.row])
            cell.populateWith(card: profiles[indexPath.row])
        }
        cell.nameLabel.sizeToFit()
        cell.descLabel.sizeToFit()
        cell.layer.cornerRadius = 6.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == profiles.count){
//            print("will show add more")
//            FCAction = "add"
//            let alert = FCAlertView()
//            alert.delegate = self
//            alert.colorScheme = Color.bondiBlue.value
//            alert.addTextField(withPlaceholder: "Name (i.e. Going Out") { (text) in
//                self.newProfileName = text!
//            }
//            alert.addTextField(withPlaceholder: "Description (i.e. Facebook, Snap") { (text) in
//                self.newProfileDesc = text!
//            }
//
//            alert.showAlert(inView: self,
//                            withTitle: "Add Profile",
//                            withSubtitle: "Enter your details below",
//                            withCustomImage: #imageLiteral(resourceName: "AppIcon"),
//                            withDoneButtonTitle: "Add",
//                            andButtons: ["Cancel"])
            return
        } else {
            let actionSheet = createStandardActionSheet(indexPath: indexPath)
            actionSheet.present(in: self, from: self.view)
        }
    }
    
    func fcAlertDoneButtonClicked(_ alertView: FCAlertView){
        // Done Button was Pressed, Perform the Action you'd like here.
        print("Done button")
        let profileName = newProfileName
        print(profileName)
        let profileDescription = newProfileDesc
        print(profileDescription)
        switch(FCAction){
        case "add":
            self.addProfile(profileName: profileName!, profileDescription: profileDescription!)
//            refreshAppData(self)
//            fetchAppData()
            break
        case "delete":
            break
        case "error":
            break
        default:
            break
        }
    }
    
    func createStandardActionSheet(indexPath: IndexPath) -> ActionSheet {
        print("CreateStandardActionSheet")
        let title = ActionSheetTitle(title: "Select an option")
        let item1 = ActionSheetItem(title: "View Code", value: "1", image: UIImage(named: "baseline_pageview_black_18pt"))
        let item2 = ActionSheetItem(title: "Edit Profile", value: "2", image: UIImage(named: "baseline_create_black_18pt"))
        let item3 = ActionSheetItem(title: "Share Profile", value: "3", image: UIImage(named: "baseline_share_black_18pt"))
        let deleteButton = ActionSheetDangerButton(title: "Delete Profile")
        let button = ActionSheetOkButton(title: "Cancel")
        return ActionSheet(items: [title, item1, item2, item3, deleteButton, button]) { _, item in
           
            guard let value = item.value as? String else {
                if item is ActionSheetDangerButton {
                    self.deleteProfile(profileId: self.profiles[indexPath.row].profileId)
                }
                return
            }
           
            if value == "1" {
                let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeViewController") as! QRCodeViewController
                //let qrCodeString = "{\"profileId\": \"\(self.profiles[indexPath.row].profileId)\"}"
               //print(qrCodeString)
                modalVC.profileId = self.profiles[indexPath.row].profileId
                self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                modalVC.modalPresentationStyle = .custom
                modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
                self.present(modalVC, animated: true, completion: nil)
            } else if value == "2" {
                let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountsForProfileViewController") as! AccountsForProfileViewController
                   // self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                let allAccounts = self.loadAppsFromDB()
                modalVC.allAccounts = allAccounts
                modalVC.accounts = self.profiles[indexPath.row].accounts
                modalVC.profileImageUrl = self.profiles[indexPath.row].imageUrl
                modalVC.profileID = self.profiles[indexPath.row].profileId
                modalVC.profileNameText = self.profiles[indexPath.row].name
                modalVC.profileDescriptionText = self.profiles[indexPath.row].description
                //modalVC.modalTransitionStyle = .crossDissolve
                //modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
                self.present(modalVC, animated: true, completion: nil)
            } else if value == "3" {
                let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeViewController") as! QRCodeViewController
                
                let qrCodeString = "{\"profileId\": \"\(self.profiles[indexPath.row].profileId)\"}"
                modalVC.profileId = self.profiles[(indexPath.row)].profileId
                modalVC.shouldShare = true
                self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                modalVC.modalPresentationStyle = .custom
                modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
                self.present(modalVC, animated: true, completion: nil)
            }
        }
    }
    
    func createAddAppActionSheet() -> ActionSheet {
        let title = ActionSheetTitle(title: "Select an option")
        let item1 = ActionSheetItem(title: "Add App", value: "1", image: UIImage(named: "baseline_pageview_black_18pt"))
        let item2 = ActionSheetItem(title: "Add Profile", value: "2", image: UIImage(named: "baseline_create_black_18pt"))
        let button = ActionSheetOkButton(title: "Cancel")
        return ActionSheet(items: [title, item1, item2, button]) { _, item in
            
            guard let value = item.value as? String else {
                return
            }
            
            if value == "1" {
                let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "AddAppViewController") as! AddAppViewController
                self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                modalVC.modalPresentationStyle = .custom
                modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
                self.present(modalVC, animated: true, completion: nil)
            } else if value == "2" {
                print("will show add more")
                self.FCAction = "add"
                let alert = FCAlertView()
                alert.delegate = self
                alert.colorScheme = Color.bondiBlue.value
                alert.addTextField(withPlaceholder: "Name (i.e. Going Out") { (text) in
                    self.newProfileName = text!
                }
                alert.addTextField(withPlaceholder: "Description (i.e. Facebook, Snap") { (text) in
                    self.newProfileDesc = text!
                }
                
                alert.showAlert(inView: self,
                                withTitle: "Add Profile",
                                withSubtitle: "Enter your details below",
                                withCustomImage: nil,
                                withDoneButtonTitle: "Add",
                                andButtons: ["Cancel"])
            }
        }
    }
    
    @objc private func refreshAppData(_ sender: Any) {
        if AWSSignInManager.sharedInstance().isLoggedIn {
            fetchAppData()
        }
    }

    private func fetchAppData() {
        loadProfiles()
       // self.updateView()
    }
    

    
    func loadCustomRefreshContents() {
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        print("The PLUS (+) button was hit")
//        if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAppViewController") as?AddAppViewController {
//            self.present(mvc, animated: true, completion: nil)
//        }
        let actionSheet = createAddAppActionSheet()
        actionSheet.present(in: self, from: self.view)
        // AddAppViewController
        // Present modally
    }
    
    func loadProfiles(){
        profiles = []
        let idString = self.credentialsManager.identityID!
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/profiles")!)
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
                print(response?.debugDescription)
            }
            //////////////////////// New stuff from Tom
            do {
                let decoder = JSONDecoder()
                let codeParser = APICodeParser(message: "\(response)")
                print (codeParser.getErrorCode())
                let JSONdata = try decoder.decode(PagedProfile.self, from: data!)
                for index in 0...JSONdata.profiles.count - 1 {
                    let profile = JSONdata.profiles[index]
                   self.profiles.append(profile)
                }
                sema.signal();
            } catch let err {
                print("Err", err)
                sema.signal(); // none found TODO: do something better than this shit.
            }
            /////////////////////////
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.refreshControl.endRefreshing()
    }
    
    // TomMiller 2018/06/27 - Added struct to interact with JSON
    struct JsonApp: Decodable {
        //["{\"accounts\":[{\"cognitoId\":\"us-east-1:bafa67f1-8631-4c47-966d-f9f069b2107c\",\"displayName\":\"tomTweets\",\"platform\":\"Twitter\",\"url\":\"http://www.twitter.com/TomsTwitter\"}]}", ""]
        var accounts: [[String: String]]
    }
    
    var JsonApps = [JsonApp]()
    
//    ///////////////////////////// NEW STUFF /////////////////////////////////
    func loadAppsFromDB() -> [PagedAccounts.Accounts] {
        var returnList: [PagedAccounts.Accounts] = []
        let idString = self.credentialsManager.identityID!
        let sema = DispatchSemaphore(value: 0);
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(idString)/accounts")!)
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
                let parser = APICodeParser(message: response.debugDescription)
                let JSONdata = try decoder.decode(PagedAccounts.self, from: data!)
                for index in 0...JSONdata.accounts.count - 1 {
                    let account = JSONdata.accounts[index]
                    returnList.append(account)
                }
                sema.signal();
            } catch let err {
                print("Err", err)
                sema.signal(); // none found TODO: do something better than this shit.
            }
            /////////////////////////
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        return returnList
    }
    
    func addProfile(profileName: String, profileDescription: String){
        // Adds a users account to the DB.
            var success = true
            let sema = DispatchSemaphore(value: 0);
            let identityId = self.credentialsManager.identityID!
            var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(identityId)/profiles/")!)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            var allAccounts:[PagedAccounts.Accounts] = loadAppsFromDB()
            var accountIds:[Int] = []
            for account in allAccounts {
                accountIds.append(account.accountId)
            }
            let json = """
                    {
                    "accounts": \(accountIds),
                    "name": "\(profileName)",
                    "description": "\(profileDescription)",
                    "imageUrl": "https://images.pexels.com/photos/708440/pexels-photo-708440.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
                    }
                    """.data(using: .utf8)!
            print("request body: \(String(data: json, encoding: .utf8)!)")
//            let jsonData = try! JSONEncoder().encode(profile)
//            let jsonString = String(data: jsonData, encoding: .utf8)!
//            print(jsonString)
            //print(postString)
            print("Got here")
            request.httpBody = json //jsonString.data(using: String.Encoding.utf8)
            var profile:SingleProfile!
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
                do {
                    let decoder = JSONDecoder()
//                    let parcer = APIMessageParser(received: response.debugDescription, parent: self)
//                    print(parcer.getTitle())
                    
                    let alert = FCAlertView()
                                alert.delegate = self
                                alert.colorScheme = Color.bondiBlue.value
                                alert.makeAlertTypeSuccess()
                                alert.showAlert(inView: self,
                                                withTitle: "Success!",
                                                withSubtitle: "Your account has been added to the database.",
                                                withCustomImage: nil,
                                                withDoneButtonTitle: nil,
                                                andButtons: [])
                    
                    profile = try decoder.decode(SingleProfile.self, from: data!)
                } catch let err {
                    print("Err", err)
                    sema.signal(); // none found TODO: do something better than this shit.
                }
                
                sema.signal()
            })
            task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        if(success){
            print("Successful addition")
            let alert = FCAlertView()
            FCAction = "" // Was 'Add' but that was causing it to add the profile twice.
            alert.delegate = self
            alert.colorScheme = Color.bondiBlue.value
            alert.showAlert(inView: self,
                            withTitle: "Success!",
                            withSubtitle: "Your account is now added to the database.",
                            withCustomImage: #imageLiteral(resourceName: "fb-icon"),
                            withDoneButtonTitle: "Okay",
                            andButtons: [""])
            let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountsForProfileViewController") as! AccountsForProfileViewController
            self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
            modalVC.allAccounts = allAccounts
            modalVC.accounts = profile.profile.accounts
            modalVC.profileImageUrl = profile.profile.imageUrl
            modalVC.profileID = profile.profile.profileId
            modalVC.profileNameText = profile.profile.name
            modalVC.profileDescriptionText = profile.profile.description
            modalVC.modalTransitionStyle = .crossDissolve
            modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
            self.present(modalVC, animated: true, completion: nil)
        } else{
            let alert = FCAlertView()
            FCAction = "error"
            alert.delegate = self
            alert.colorScheme = Color.bondiBlue.value
            alert.showAlert(inView: self,
                            withTitle: "Oops!",
                            withSubtitle: "Something went wrong. Try again. If this keeps happening, contact our support team.",
                            withCustomImage: #imageLiteral(resourceName: "fb-icon"),
                            withDoneButtonTitle: "Okay",
                            andButtons: [""])
        }
    }
    
    func deleteProfile(profileId: Int){
        var success = true
        let sema = DispatchSemaphore(value: 0);
        let identityId = self.credentialsManager.identityID!
        var request = URLRequest(url:URL(string: "https://api.tc2pro.com/users/\(identityId)/profiles/\(profileId)")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
       
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
            sema.signal()
        })
        task.resume()
        sema.wait(timeout: DispatchTime.distantFuture)
        if(success){
            let alert = FCAlertView()
            FCAction = "delete"
            alert.delegate = self
            alert.colorScheme = Color.bondiBlue.value
            alert.showAlert(inView: self,
                            withTitle: "Success!",
                            withSubtitle: "Your account is now deleted from the database.",
                            withCustomImage: #imageLiteral(resourceName: "fb-icon"),
                            withDoneButtonTitle: "Okay",
                            andButtons: [""])
            refreshAppData(self)
            fetchAppData()
        } else{
            let alert = FCAlertView()
            FCAction = "error"
            alert.delegate = self
            alert.colorScheme = Color.bondiBlue.value
            alert.showAlert(inView: self,
                            withTitle: "Oops!",
                            withSubtitle: "Something went wrong. Try again. If this keeps happening, contact our support team.",
                            withCustomImage: #imageLiteral(resourceName: "fb-icon"),
                            withDoneButtonTitle: "Okay",
                            andButtons: [""])
        }
    }
}

extension UICollectionView {
    
    func snapToCell(velocity: CGPoint, targetOffset: UnsafeMutablePointer<CGPoint>, contentInset: CGFloat = 0, spacing: CGFloat = 0, indexPath: IndexPath) {
        // No snap needed as we're at the end of the scrollview
        guard (contentOffset.x + frame.size.width) < contentSize.width else {
            return
        }
  //      let indexPath =  indexPathForItem(at: targetOffset.pointee)
//        guard let indexPath = indexPathForItem(at: targetOffset.pointee) else {
//            print("target offset: \(targetOffset.pointee)")
//            return
//        }
        guard let cellLayout = layoutAttributesForItem(at: indexPath) else {
            return
        }
        
        var offset = targetOffset.pointee
        if velocity.x < 0 {
            offset.x = cellLayout.frame.minX - max(contentInset, spacing)
        } else {
            offset.x = cellLayout.frame.maxX - contentInset + min(contentInset, spacing)
        }
        
        targetOffset.pointee = offset
    }
    
}


extension String
{
    func replacingLastOccurrenceOfString(_ searchString: String,
                                         with replacementString: String,
                                         caseInsensitive: Bool = true) -> String
    {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        
        if let range = self.range(of: searchString,
                                  options: options,
                                  range: nil,
                                  locale: nil) {
            
            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
    
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
