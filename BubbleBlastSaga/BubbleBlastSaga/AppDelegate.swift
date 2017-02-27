//
//  AppDelegate.swift
//  BubbleBlastSaga
//
//  Created by Edmund Mok on 16/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        generatePreloadedInfo()
        return true
    }
    
    private func generatePreloadedInfo() {
        let preloadedLevels = ["Chain", "RainbowPizza", "Star"]
        
        preloadedLevels.forEach{ generatePreloaded(level: $0) }
    }
    
    private func generatePreloaded(level: String) {
        // Get main bundle path
        guard let gridBundlePath =  Bundle.main.path(forResource: level, ofType: Constants.fileExtension),
            let imageBundlePath =  Bundle.main.path(forResource: level, ofType: Constants.pngExtension),
            let infoBundlePath =  Bundle.main.path(forResource: level, ofType: Constants.plistExtension) else {
                return
        }
        
        // Get documents path
        let gridDocumentsPath = FileUtility.getFileURL(for: level, and: Constants.fileExtension).path
        let imageDocumentsPath = FileUtility.getFileURL(for: level, and: Constants.pngExtension).path
        let infoDocumentsPath = FileUtility.getFileURL(for: level, and: Constants.plistExtension).path
        
        let fileManager = FileManager.default
        
        // Don't overwrite if file already exists
        guard !fileManager.fileExists(atPath: gridDocumentsPath) else {
            return
        }
        
        // Copy from bundle to documents
        try? fileManager.copyItem(atPath: gridBundlePath, toPath: gridDocumentsPath)
        try? fileManager.copyItem(atPath: imageBundlePath, toPath: imageDocumentsPath)
        try? fileManager.copyItem(atPath: infoBundlePath, toPath: infoDocumentsPath)

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

