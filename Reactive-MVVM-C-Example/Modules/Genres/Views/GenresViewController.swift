//
//  GenresViewController.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import UIKit
import Core
import RxCocoa
import RxSwift

class GenresViewController: UIViewController {
    
    @IBOutlet private weak var errorTitleLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var viewModel: GenresViewModel!
    
    private let disposeBag = DisposeBag()
}

extension GenresViewController: ViewType {
    
    func bindViewModel(viewModel: GenresViewModel) -> GenresViewModel.Output {
        let input = GenresViewModel.Input(ready: .just(()),
                                          close: rx.deallocated.asObservable(),
                                          selected: collectionView.rx.itemSelected.asObservable())
        let output = viewModel.transform(input: input)
        
        output
            .results
            .drive(collectionView.rx.items(cellIdentifier: String(describing: GenreCollectionViewCell.self), cellType: GenreCollectionViewCell.self)) { row, element, cell in
                cell.viewModel = element
            }
            .disposed(by: disposeBag)
        
        output
            .loading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output
            .error
            .map({ !$0 })
            .drive(errorTitleLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        return output
    }
    
}
