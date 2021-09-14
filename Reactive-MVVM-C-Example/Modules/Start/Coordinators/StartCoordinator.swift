//
//  StartCoordinator.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 03.09.2021.
//

import Foundation
import UIKit
import Core
import RxSwift

protocol StartCoordinatorType {
    func coordinateToMainViewController() -> Observable<MainCoordinator.ResultType>
}

class StartCoordinator: BaseCoordinator<Never>, StartCoordinatorType {
    
    private weak var rootViewController: UINavigationController?
    private weak var startViewController: StartViewController?
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<ResultType> {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let startViewController = storyboard.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
        self.startViewController = startViewController

        let viewModel = StartViewModel(coordinator: self)
        startViewController.viewModel = viewModel
        startViewController.bindViewModelOnViewWillAppear(viewModel: viewModel)
            .subscribe()
            .disposed(by: disposeBag)
        
        rootViewController?.pushViewController(startViewController, animated: true)
        
        return .never()
    }
    
    func coordinateToMainViewController() -> Observable<MainCoordinator.ResultType> {
        guard let viewController = startViewController else {
            return .empty()
        }
        let mainCoordinator = MainCoordinator(rootViewController: viewController)
        return coordinate(to: mainCoordinator)
    }
    
}
