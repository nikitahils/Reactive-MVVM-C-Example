//
//  DiscoverResultsViewController.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 02.09.2021.
//

import Foundation
import UIKit
import Core
import RxCocoa
import RxSwift

class DiscoverResultsViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    var viewModel: DiscoverResultsViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
}

extension DiscoverResultsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 58)
    }
    
}

extension DiscoverResultsViewController: ViewType {
    
    func bindViewModel(viewModel: DiscoverResultsViewModel) -> DiscoverResultsViewModel.Output {
        let input = DiscoverResultsViewModel.Input(ready: .just(()),
                                                   selected: collectionView.rx.itemSelected.asObservable(),
                                                   close: rx.deallocated.asObservable())
        let output = viewModel.transform(input: input)
        
        output.error
            .map { !$0 }
            .drive(errorLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.loading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output.results
            .drive(collectionView.rx.items(cellIdentifier: String(describing: DiscoverResultsCollectionViewCell.self), cellType: DiscoverResultsCollectionViewCell.self)) { row , viewModel, cell in
                cell.viewModel = viewModel
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
}
