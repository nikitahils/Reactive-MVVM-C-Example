//
//  BaseCoordinator.swift
//  Core
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import RxSwift

open class BaseCoordinator<R> {
    
    public typealias ResultType = R
    
    public typealias CoordinatorResultType = ResultType
    
    public let disposeBag = DisposeBag()
    
    private let identifier = UUID()
    private var childCoordinators = [UUID: Any]()

    public init() {}
    
    private func add<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    private func remove<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }

    public func coordinate<T>(to coordinator: BaseCoordinator<T>) -> Observable<T> {
        add(coordinator: coordinator)
        return coordinator.start()
            .do(onNext: { [weak self] _ in
                self?.remove(coordinator: coordinator)
            })
    }

    open func start() -> Observable<CoordinatorResultType> {
        fatalError("\(#function) must be implemented")
    }
}
