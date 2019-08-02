//
//  AppDelegate.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 8/1/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import UIKit
import AssessmentCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let settings = [
            "client_name"   : "easipro-clinic",
            "client_id"     : "app-client-id",
            "redirect"      : "easipro-clinic://smartcallback",
            "scope"         : "openid profile user/*.* launch"
        ]
        let smart_baseURL = URL(string: "https://r4.smarthealthit.org")!
        SMARTClient.shared.smart_settings = settings
        SMARTClient.shared.smart_endpoint = smart_baseURL
        SMARTClient.shared.acClient = ACClient(baseURL: URL(string: "https://www.assessmentcenter.net/ac_api/2014-01/")!, accessIdentifier: "<# - AC Access Identifier - #>", token: "<# - AC Token - #>")

        
        let splitViewController = window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //  SMART handle authorization
        if let client = SMARTClient.shared.client, client.awaitingAuthCallback {
            return client.didRedirect(to: url)
        }
        
        return true
    }


    

}

