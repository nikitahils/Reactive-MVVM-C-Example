//
//  StartViewModelTests.swift
//  Reactive-MVVM-TestTests
//
//  Created by Nikita Tolkachev on 08.09.2021.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
import Core
@testable import Reactive_MVVM_C_Example

struct StartCoordinatorMock: StartCoordinatorType {
    private var block: () -> Observable<MainCoordinator.ResultType>
    
    init(block: @escaping () -> Observable<MainCoordinator.ResultType>) {
        self.block = block
    }
    
    func coordinateToMainViewController() -> Observable<MainCoordinator.ResultType> {
        block()
    }
}

class StartViewModelTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    func testStartTap() {
        //1
        let coordinator = StartCoordinatorMock {
            self.scheduler.createColdObservable([.next(20, ()), .completed(20)]).asObservable()
        }
        let viewModel = StartViewModel(coordinator: coordinator)
        //2
        let startTap = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: StartViewModel.Input(startTap: startTap))
        //3
        let result = scheduler.createObserver(VoidResult.self)
        output.mainCoordinatorResult
            .drive(result)
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(result.events, [
            .next(30, .void),
        ])
    }
    
}
