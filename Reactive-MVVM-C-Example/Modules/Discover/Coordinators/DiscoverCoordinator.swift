//
//  DiscoverCoordinator.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import UIKit
import Core
import RxSwift

protocol DiscoverCoordinatorType {
    func coordinateToGenresViewController() -> Observable<GenresCoordinator.ResultType>
    func coordinateToDiscoverResultsViewController(with genre: Genre, movieObserver: AnyObserver<Movie?>) -> Observable<DiscoverResultsCoordinator.ResultType>
}

class DiscoverCoordinator: BaseCoordinator<Void>, DiscoverCoordinatorType {
    
    private weak var rootViewController: UITabBarController?
    private weak var discoverViewController: DiscoverViewController?
    
    init(rootViewController: UITabBarController) {
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<ResultType> {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let discoverViewController = storyboard.instantiateViewController(withIdentifier: "DiscoverViewController") as! DiscoverViewController
        self.discoverViewController = discoverViewController
        
        let viewModel = DiscoverViewModel(coordinator: self)
        discoverViewController.viewModel = viewModel
        
        rootViewController?.setViewControllers([discoverViewController], animated: false)
        
        return discoverViewController.bindViewModelOnViewWillAppear(viewModel: viewModel)
            .flatMap { $0.close.take(1) }
            .do(onNext: { [weak self] _ in
                self?.discoverViewController?.dismiss(animated: true, completion: nil)
            })
    }
    
    func coordinateToGenresViewController() -> Observable<GenresCoordinator.ResultType> {
        guard let viewController = discoverViewController else {
            return .empty()
        }
        let genresCoordinator = GenresCoordinator(rootViewController: viewController)
        return coordinate(to: genresCoordinator)
    }
    
    func coordinateToDiscoverResultsViewController(with genre: Genre, movieObserver: AnyObserver<Movie?>) -> Observable<DiscoverResultsCoordinator.ResultType> {
        guard let navigationController = discoverViewController?.navigationController else {
            return .empty()
        }
        let discoverResultsCoordinator = DiscoverResultsCoordinator(rootViewController: navigationController, genre: genre, movieObserver: movieObserver)
        return self.coordinate(to: discoverResultsCoordinator)
    }
    
}
