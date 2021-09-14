//
//  MainCoordinator.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import UIKit
import Core
import RxSwift
import RxCocoa

class MainCoordinator: BaseCoordinator<Void> {
    
    private weak var rootViewController: UIViewController?
    private weak var mainTabBarViewController: UITabBarController?
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<ResultType> {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let mainTabBarViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarViewController") as! UITabBarController
        self.mainTabBarViewController = mainTabBarViewController
        
        rootViewController?.navigationController?.pushViewController(mainTabBarViewController, animated: true)
        
        return coordinateToDiscoverViewController()
    }
    
    func coordinateToDiscoverViewController() -> Observable<DiscoverCoordinator.ResultType> {
        guard let viewController = mainTabBarViewController else {
            return .empty()
        }
        let discoverCoordinator = DiscoverCoordinator(rootViewController: viewController)
        return coordinate(to: discoverCoordinator)
    }
}
