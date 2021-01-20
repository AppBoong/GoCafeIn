//
//  AppDelegate.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyAfMHS_sKTYQb6U7hMkuyc1GY10PS1x6-0")
        GMSPlacesClient.provideAPIKey("AIzaSyAfMHS_sKTYQb6U7hMkuyc1GY10PS1x6-0")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        if #available(iOS 13.0, *) {
              
          } else {
        if Auth.auth().currentUser == nil {
            
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

            window?.rootViewController = vc
            window?.makeKeyAndVisible()
             }
             else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
                
                
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
             }
          }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

