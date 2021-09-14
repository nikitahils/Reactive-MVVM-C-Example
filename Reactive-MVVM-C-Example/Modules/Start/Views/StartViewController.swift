//
//  StartViewController.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 03.09.2021.
//

import Foundation
import UIKit
import Core
import RxSwift

class StartViewController: UIViewController {
    
    @IBOutlet private weak var startButton: UIButton!
    
    var viewModel: StartViewModel!
    
    private let disposeBag = DisposeBag()
    
}

extension StartViewController: ViewType {
    
    func bindViewModel(viewModel: StartViewModel) -> StartViewModel.Output {
        let input = StartViewModel.Input(startTap: startButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        return output
    }

}
