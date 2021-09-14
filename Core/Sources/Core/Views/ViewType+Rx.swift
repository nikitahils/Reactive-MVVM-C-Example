//
//  ViewType+Rx.swift
//  Core
//
//  Created by Nikita Tolkachev on 02.09.2021.
//

import Foundation
import UIKit
import RxSwift

public extension ViewType where Self: UIViewController {
    
    func bindViewModelOnViewWillAppear(viewModel: ViewModel) -> Observable<ViewModel.Output> {
        rx.viewWillAppear
            .take(1)
            .asObservable()
            .map { _ in
                self.bindViewModel(viewModel: viewModel)
            }
    }
    
}
