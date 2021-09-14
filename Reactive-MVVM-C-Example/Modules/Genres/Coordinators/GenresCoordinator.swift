//
//  GenresCoordinator.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import UIKit
import Core
import RxSwift
import RxCocoa

class GenresCoordinator: BaseCoordinator<GenresCoordinator.Result> {
    
    private weak var rootViewController: UIViewController?
    private weak var genresViewController: GenresViewController?
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<ResultType> {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let genresViewController = storyboard.instantiateViewController(withIdentifier: "GenresViewController") as! GenresViewController
        self.genresViewController = genresViewController
        
        let viewModel = GenresViewModel()
        genresViewController.viewModel = viewModel
        
        rootViewController?.present(genresViewController, animated: true, completion: nil)
        
        return genresViewController.bindViewModelOnViewWillAppear(viewModel: viewModel)
            .flatMap { output -> Observable<GenresCoordinator.Result> in
                
                let didClose = output.close.map({ GenresCoordinator.Result.cancel })
                let didSelectGenre = output.selected.map({ GenresCoordinator.Result.genreSelected($0) })
                
                return Observable.merge(didClose, didSelectGenre)
                    .take(1)
            }
            .do(onNext: { [weak self] _ in
                self?.genresViewController?.dismiss(animated: true, completion: nil)
            })
    }
    
}

extension GenresCoordinator {
    
    enum Result {
        case cancel
        case genreSelected(Genre)
        
        var genre: Genre? {
            if case .genreSelected(let genre) = self {
                return genre
            }
            return nil
        }
    }
    
}
