//
//  ViewType.swift
//  Core
//
//  Created by Nikita Tolkachev on 01.09.2021.
//

import Foundation
import UIKit

public protocol ViewType {
    associatedtype ViewModel: ViewModelType
    
    var viewModel: ViewModel! { get set }
    
    func bindViewModel(viewModel: ViewModel) -> ViewModel.Output
}
