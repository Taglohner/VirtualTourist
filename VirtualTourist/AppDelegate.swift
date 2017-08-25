//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Steven Taglohner on 13/08/2017.
//  Copyright © 2017 Steven Taglohner. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
//    func checkIfFirstLaunch() {
//        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
//            print("App has launched before")
//        } else {
//            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
//            UserDefaults.standard.synchronize()
//        }
//    }
    
    static let stack = CoreDataStack(modelName: "VirtualTourist")!
    
    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.stack.applicationDocumentsDirectory()
        
        // Start Autosaving
        AppDelegate.stack.autoSave(60)
        return true
    }
}

