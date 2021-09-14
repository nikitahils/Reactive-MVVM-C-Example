//
//  MovieCoordinator.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 06.09.2021.
//

import Foundation
import UIKit
import Core
import RxSwift

class MovieCoordinator: BaseCoordinator<Void> {
    
    private weak var rootViewController: UIViewController?
    private weak var movieViewController: MovieViewController?
    private let movieId: Int
    
    init(rootViewController: UIViewController, movieId: Int) {
        self.rootViewController = rootViewController
        self.movieId = movieId
    }
    
    override func start() -> Observable<ResultType> {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let movieViewController = storyboard.instantiateViewController(withIdentifier: "MovieViewController") as! MovieViewController
        self.movieViewController = movieViewController
        
        let viewModel = MovieViewModel(movieId: movieId)
        movieViewController.viewModel = viewModel
        
        rootViewController?.navigationController?.pushViewController(movieViewController, animated: true)
        
        return movieViewController.bindViewModelOnViewWillAppear(viewModel: viewModel)
            .flatMap { $0.close.take(1) }
            .do(onNext: { [weak movieViewController] in
                movieViewController?.navigationController?.popViewController(animated: true)
            })
            
    }
}
