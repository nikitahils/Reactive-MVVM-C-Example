//
//  StartViewModel.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 03.09.2021.
//

import Foundation
import Core
import RxCocoa
import RxSwift

class StartViewModel: ViewModelType {
    
    struct Input {
        let startTap: Observable<Void>
    }
    
    struct Output {
        let mainCoordinatorResult: Driver<VoidResult>
    }
    
    private let disposeBag = DisposeBag()
    
    private let coordinator: StartCoordinatorType
    
    init(coordinator: StartCoordinatorType) {
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {
        let mainCoordinatorResult = input.startTap
            .flatMap { [coordinator] _ in
                coordinator.coordinateToMainViewController()
            }
            .map { _ in VoidResult.void }
            .asDriver(onErrorJustReturn: .void)
        
        mainCoordinatorResult
            .drive()
            .disposed(by: disposeBag)
        
        return Output(mainCoordinatorResult: mainCoordinatorResult)
    }
}
