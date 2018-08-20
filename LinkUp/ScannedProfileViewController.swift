//
//  ScannedProfileViewController.swift
//  LinkUp
//
//  Created by Christopher Deck on 8/20/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit

class ScannedProfileViewController: UIViewController {
    
    var nativeApps: [Apps]!
    var safariApps: [Apps]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(safariApps)
        print(nativeApps)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
