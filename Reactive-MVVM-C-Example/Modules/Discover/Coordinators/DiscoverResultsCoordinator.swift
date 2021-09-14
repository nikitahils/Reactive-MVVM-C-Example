//
//  DiscoverResultsCoordinator.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 03.09.2021.
//

import Foundation
import UIKit
import RxSwift
import Core

protocol DiscoverResultsCoordinatorType {
    func coordinateToMovieViewController(movieId: Int) -> Observable<MovieCoordinator.ResultType>
}

class DiscoverResultsCoordinator: BaseCoordinator<Void>, DiscoverResultsCoordinatorType {
    
    private weak var rootViewController: UINavigationController?
    private weak var discoverResultsViewController: DiscoverResultsViewController?
    private let genre: Genre
    private let movieObserver: AnyObserver<Movie?>
    
    init(rootViewController: UINavigationController, genre: Genre, movieObserver: AnyObserver<Movie?>) {
        self.rootViewController = rootViewController
        self.genre = genre
        self.movieObserver = movieObserver
    }
    
    override func start() -> Observable<DiscoverResultsCoordinator.ResultType> {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let discoverResultsViewController = storyboard.instantiateViewController(withIdentifier: "DiscoverResultsViewController") as! DiscoverResultsViewController
        self.discoverResultsViewController = discoverResultsViewController
        
        let viewModel = DiscoverResultsViewModel(coordinator: self,
                                                 genre: genre,
                                                 movieObserver: movieObserver)
        discoverResultsViewController.viewModel = viewModel
        
        rootViewController?.pushViewController(discoverResultsViewController, animated: true)

        return discoverResultsViewController.bindViewModelOnViewWillAppear(viewModel: viewModel)
            .flatMap { $0.close.take(1) } 
            .do(onNext: { [weak self] _ in
                self?.discoverResultsViewController?.navigationController?.popViewController(animated: true)
            })
    }
    
    func coordinateToMovieViewController(movieId: Int) -> Observable<MovieCoordinator.ResultType> {
        guard let viewController = discoverResultsViewController else {
            return .empty()
        }
        let movieCoordinator = MovieCoordinator(rootViewController: viewController, movieId: movieId)
        return coordinate(to: movieCoordinator)
    }
}
