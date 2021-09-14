//
//  DiscoverViewController.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import UIKit
import Core
import RxSwift
import RxCocoa

class DiscoverViewController: UIViewController {
    
    @IBOutlet private weak var genreNameLabel: UILabel!
    @IBOutlet private weak var discoverButton: UIButton!
    @IBOutlet private weak var selectedMovieTitle: UILabel!
    
    var viewModel: DiscoverViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    }
}

extension DiscoverViewController: ViewType {
    
    func bindViewModel(viewModel: DiscoverViewModel) -> DiscoverViewModel.Output {
        let input = DiscoverViewModel.Input(
            genreTap: tabBarController?.navigationItem.rightBarButtonItem?.rx.tap.asObservable() ?? .never(),
            discoverTap: discoverButton.rx.tap.asObservable(),
            close: rx.deallocated
        )
        
        let output = viewModel.transform(input: input)

        output.selectedGenreTitle
            .drive(genreNameLabel.rx.text)
            .disposed(by: disposeBag)

        output.selectedMovieTitle
            .drive(selectedMovieTitle.rx.text)
            .disposed(by: disposeBag)
        
        output.discoverTapsAvailable
            .drive(discoverButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.discoverCoordinatorResult
            .drive()
            .disposed(by: disposeBag)
        
        return output
    }
    
}
