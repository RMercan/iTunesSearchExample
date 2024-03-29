//
//  AppDelegate.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 1.03.2024.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: HomepageViewController())
        window?.makeKeyAndVisible()
        
        return true
    }

}




