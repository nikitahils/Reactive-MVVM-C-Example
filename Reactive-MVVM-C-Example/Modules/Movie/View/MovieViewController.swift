//
//  MovieViewController.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 06.09.2021.
//

import Foundation
import UIKit
import Core
import RxSwift

class MovieViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    var viewModel: MovieViewModel!
    
    private let disposeBag = DisposeBag()
}

extension MovieViewController: ViewType {
    
    func bindViewModel(viewModel: MovieViewModel) -> MovieViewModel.Output {
        let input = MovieViewModel.Input(ready: .just(()),
                                         close: rx.deallocated)
        let output = viewModel.transform(input: input)
        
        output.title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.releaseDate
            .drive(releaseDateLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.description
            .drive(descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.loading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output.error
            .map { !$0 }
            .drive(errorLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        return output
    }
    
}
