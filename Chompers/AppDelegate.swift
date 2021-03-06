//
//  AppDelegate.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import PinpointKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DownloadManagerInjector {

    var window: UIWindow?
    static let pinpointKit = PinpointKit(feedbackRecipients: ["chompersapp@gmail.com"])

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        #if !DEV
        Fabric.with([Crashlytics.self])
        #endif
        self.window = ShakeDetectingWindow(frame: UIScreen.main.bounds, delegate: AppDelegate.pinpointKit)
        self.window?.rootViewController = MainViewController()
        self.window?.makeKeyAndVisible()

        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20)
            ], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white
        ]
        UINavigationBar.appearance().barTintColor = UIColor.psych5
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.psych1.withAlphaComponent(1)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).alpha = 1
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).isOpaque = true

        return true
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
        self.downloadManager.stopDownloads()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
