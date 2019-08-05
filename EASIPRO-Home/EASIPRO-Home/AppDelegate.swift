//
//  AppDelegate.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 8/5/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import UIKit
import AssessmentCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let settings = [
            "client_name"   : "easipro-home",
            "client_id"     : "app-client-id",
            "redirect"      : "easipro-home://smartcallback",
            "scope"         : "openid profile user/*.* launch"
        ]
        let smart_baseURL = URL(string: "https://r4.smarthealthit.org")!
        SMARTClient.shared.smart_settings = settings
        SMARTClient.shared.smart_endpoint = smart_baseURL
        SMARTClient.shared.acClient = ACClient(baseURL: URL(string: "https://www.assessmentcenter.net/ac_api/2014-01/")!, accessIdentifier: "<# - AC Access Identifier - #>", token: "<# - AC Token - #>")

        let splitViewController = window!.rootViewController as! UISplitViewController

        
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

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

