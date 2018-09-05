//
//  AppDelegate.swift
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
import GoogleSignIn
import FacebookCore
import SideMenuSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        UITabBar.appearance().tintColor = UIColor.init(red: 42/255, green: 147/255, blue: 213/255, alpha: 1)
       // UITabBar.appearance().unselectedItemTintColor = UIColor.init(red: 119/255, green: 201/255, blue: 212/255, alpha: 1) //feather (light blue)
        //UITabBar.appearance().unselectedItemTintColor = UIColor.init(red: 87/255, green: 188/255, blue: 144/255, alpha: 1) //marine (medium green)
       // UITabBar.appearance().unselectedItemTintColor = UIColor.init(red: 165/255, green: 165/255, blue: 175/255, alpha: 1)
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = .clear //UIColor.init(red: 174/255, green: 217/255, blue: 218/255, alpha: 1)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        //UINavigationBar.appearance().isTranslucent = true
    
//        SideMenuController.preferences.basic.menuWidth = 240
//        SideMenuController.preferences.basic.defaultCacheKey = "0"
        
        return AWSMobileClient.sharedInstance().interceptApplication(
            application, didFinishLaunchingWithOptions:
            launchOptions)
    }
    
    
    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        
        return AWSMobileClient.sharedInstance().interceptApplication(
            application, open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

