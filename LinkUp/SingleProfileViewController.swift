//
//  SingleProfileViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 9/6/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import FCAlertView
import CDAlertView
import SafariServices

class SingleProfileViewController: UIViewController, SFSafariViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, FCAlertViewDelegate, HalfModalPresentable {

    @IBOutlet var profileImage: ProfileImage!
    @IBOutlet var doneButton: UIBarButtonItem!
    var allAccounts:[PagedAccounts.Accounts]!
    @IBOutlet var profileTableView: UITableView!
    var profile:SingleProfile.Profile!
    @IBOutlet var navigationBar: UINavigationBar!
    var gradient: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = .clear
        self.view.backgroundColor = Color.chill.value
        createGradientLayer()
        self.profileTableView.backgroundColor = UIColor.clear
      //
        self.profileImage.center = self.view.center
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true;
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        profileImage.sd_setImage(with: URL(string: profile.imageUrl ?? "https://images.pexels.com/photos/708440/pexels-photo-708440.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"), completed: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        print("hit dismiss")
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        } else {
            return allAccounts.count
        }
    }
    
    // This is where the table cells on the main page are modeled from.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Create an object of the dynamic cell “ProfileCell”
            if(indexPath.row == 0){
                let cell:ProfileTableViewCell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
                
                cell.NameLabel.text = "Name"
                cell.profileNameLabel.text = profile.name // allAccounts[indexPath]
                cell.layer.backgroundColor = UIColor.white.cgColor
                return cell
            } else {
                let cell:ProfileTableViewCell = profileTableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
                
                cell.NameLabel.text = "Description"
                cell.profileNameLabel.text = profile.description
                cell.layer.backgroundColor = UIColor.white.cgColor
                return cell
            }
            
        } else {
            // Create an object of the dynamic cell “AccountsCell”
            let cell:ScannedProfileTableViewCell = profileTableView.dequeueReusableCell(withIdentifier: "AccountsCell", for: indexPath) as! ScannedProfileTableViewCell
            print("Adding to table view now: \(cell)")
            cell.NameLabel.text = allAccounts[indexPath.row].displayName
            switch allAccounts[indexPath.row].platform {
            case "Facebook":
                cell.appImage.image = UIImage(named: "fb-icon")
            case "Twitter":
                cell.appImage.image = UIImage(named: "twitter_icon")
            case "Instagram":
                cell.appImage.image = UIImage(named: "Instagram_icon")
            case "Snapchat":
                cell.appImage.image = UIImage(named: "snapchat_icon")
            case "GooglePlus":
                cell.appImage.image = UIImage(named: "google_plus_icon")
            case "LinkedIn":
                cell.appImage.image = UIImage(named: "linked_in_logo")
            case "Xbox":
                cell.appImage.image = UIImage(named: "xbox")
            case "PSN":
                cell.appImage.image = UIImage(named: "play-station")
            case "Twitch":
                cell.appImage.image = UIImage(named: "twitch")
            case "Custom":
                cell.appImage.image = UIImage(named: "custom")
            default:
                cell.appImage.image = UIImage(named: "AppIcon")
            }
            //cell.NameLabel.textColor = UIColor.white
            cell.layer.backgroundColor = UIColor.white.cgColor
            cell.url = allAccounts[indexPath.row].url
            cell.id = Int(allAccounts[indexPath.row].accountId)
            cell.userId = allAccounts[indexPath.row].userId
            cell.username.text = "@\(allAccounts[indexPath.row].username)"
            cell.platform = allAccounts[indexPath.row].platform
            cell.cognitoId = allAccounts[indexPath.row].cognitoId
            return cell
        }
        //return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            self.profileTableView.deselectRow(at: indexPath, animated: true)
        } else {
            let cell = profileTableView.cellForRow(at: indexPath) as! ScannedProfileTableViewCell
            let url = URL(string: cell.url!)!
            if(UIApplication.shared.canOpenURL(url)){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let svc = SFSafariViewController(url: url)
                svc.delegate = self
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.pushViewController(svc, animated: true)
            }
            self.profileTableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        if(section == 0){
            vw.backgroundColor = .clear
            let textView = UITextView()
            textView.text = "Profile"
            textView.font = UIFont(name: "Trench", size: UIFont.labelFontSize)
            textView.textColor = .black
            textView.sizeToFit()
            textView.backgroundColor = .clear
            vw.addSubview(textView)
        } else {
            vw.backgroundColor = .clear
            let textView = UITextView()
            textView.text = "Connect Social Accounts"
            textView.font = UIFont(name: "Trench", size: UIFont.labelFontSize)
            textView.textColor = .black
            textView.sizeToFit()
            textView.backgroundColor = .clear
            vw.addSubview(textView)
        }
        
        return vw
    }
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let gradientView = UIView(frame: self.view.bounds)
        gradient.frame = view.frame
        gradient.colors = [Color.glass.value.cgColor, Color.glass.value.cgColor]
        gradient.locations = [0.0, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        self.view.sendSubview(toBack: gradientView)
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
