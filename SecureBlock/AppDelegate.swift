//
//  AppDelegate.swift
//  SecureBlock
//
//  Created by Zach Kagin on 1/26/19.
//  Copyright © 2019 Zach Kagin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let rootViewController = RootViewController()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        window?.backgroundColor = UIColor.white
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        rootViewController.checkBlockingEnabled()
    }
}

