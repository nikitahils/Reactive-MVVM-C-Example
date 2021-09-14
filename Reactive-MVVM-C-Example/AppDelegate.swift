//
//  AppDelegate.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 29.08.2021.
//

import UIKit
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var startCoordinator: StartCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let rootViewController = window?.rootViewController as? UINavigationController {
            startCoordinator = StartCoordinator(rootViewController: rootViewController)
            _ = startCoordinator?
                .start()
                .subscribe()
        }
        
        return true
    }

}

