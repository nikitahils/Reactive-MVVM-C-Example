//
//  DiscoverResultsViewModelTests.swift
//  Reactive-MVVM-TestTests
//
//  Created by Nikita Tolkachev on 08.09.2021.
//

import Foundation
import XCTest
import RxTest
import RxSwift
import RxCocoa
import Core
@testable import Reactive_MVVM_C_Example

class DiscoverResultsViewModelTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    func testResults() {
        //1
        let serviceMock = DiscoverServiceMock { _, _ in
            let result = DiscoverMovieResult(JSONString: json)!
            return self.scheduler.createColdObservable([.next(5, result), .completed(5)]).asSingle()
        }
        let coordinator = DiscoverResultsCoordinatorMock { _ in
            .never()
        }
        let genre = Genre(id: 101, name: "Test")
        let movieObserver = scheduler.createObserver(Movie?.self)
        let viewModel = DiscoverResultsViewModel(coordinator: coordinator,
                                                 genre: genre,
                                                 movieObserver: movieObserver.asObserver(),
                                                 discoverService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: DiscoverResultsViewModel.Input(ready: ready,
                                                                               selected: .never(),
                                                                               close: .never()))
        //3
        let results = scheduler.createObserver([DiscoverResultItemViewModel].self)
        output.results
            .drive(results)
            .disposed(by: disposeBag)
        
        //4
        scheduler.start()
        //5
        XCTAssertEqual(results.events, [
            .next(15, [DiscoverResultItemViewModel(Movie(id: 706972, title: "Narco Sub")),
                       DiscoverResultItemViewModel(Movie(id: 860425, title: "Breathless")),
                       DiscoverResultItemViewModel(Movie(id: 597433, title: "Beckett")),
                       DiscoverResultItemViewModel(Movie(id: 672322, title: "Rurouni Kenshin: The Beginning")),
                       DiscoverResultItemViewModel(Movie(id: 615658, title: "Awake")),
                       DiscoverResultItemViewModel(Movie(id: 315635, title: "Spider-Man: Homecoming"))]),
            .completed(15)
        ])
    }
    
    func testMovieObserver() {
        //1
        let serviceMock = DiscoverServiceMock { _, _ in
            let result = DiscoverMovieResult(JSONString: json)!
            return self.scheduler.createColdObservable([.next(5, result), .completed(5)]).asSingle()
        }
        let coordinator = DiscoverResultsCoordinatorMock { _ in
            .never()
        }
        let genre = Genre(id: 101, name: "Test")
        let movieObserver = scheduler.createObserver(Movie?.self)
        let viewModel = DiscoverResultsViewModel(coordinator: coordinator,
                                                 genre: genre,
                                                 movieObserver: movieObserver.asObserver(),
                                                 discoverService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let selected = scheduler.createColdObservable([.next(20, IndexPath(item: 0, section: 0)),
                                                       .next(30, IndexPath(item: 2, section: 0))]).asObservable()
        _ = viewModel.transform(input: DiscoverResultsViewModel.Input(ready: ready,
                                                                      selected: selected,
                                                                      close: .never()))
        //3
        scheduler.start()
        //4
        XCTAssertEqual(movieObserver.events, [
            .next(20, Movie(id: 706972, title: "Narco Sub")),
            .next(30, Movie(id: 597433, title: "Beckett")),
        ])
    }
    
    func testMovieCoordinatorResult() {
        //1
        let serviceMock = DiscoverServiceMock { _, _ in
            let result = DiscoverMovieResult(JSONString: json)!
            return self.scheduler.createColdObservable([.next(5, result), .completed(5)]).asSingle()
        }
        let coordinator = DiscoverResultsCoordinatorMock { _ in
            self.scheduler.createColdObservable([.next(10, ())]).asObservable()
        }
        let genre = Genre(id: 101, name: "Test")
        let movieObserver = scheduler.createObserver(Movie?.self)
        let viewModel = DiscoverResultsViewModel(coordinator: coordinator,
                                                 genre: genre,
                                                 movieObserver: movieObserver.asObserver(),
                                                 discoverService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let selected = scheduler.createColdObservable([.next(20, IndexPath(item: 0, section: 0))]).asObservable()
        let output = viewModel.transform(input: DiscoverResultsViewModel.Input(ready: ready,
                                                                               selected: selected,
                                                                               close: .never()))
        //3
        let movieCoordinatorResult = scheduler.createObserver(VoidResult.self)
        output.movieCoordinatorResult
            .drive(movieCoordinatorResult)
            .disposed(by: disposeBag)
        
        //4
        scheduler.start()
        //5
        XCTAssertEqual(movieCoordinatorResult.events, [
            .next(30, .void),
        ])
    }
    
    func testLoading() {
        //1
        let serviceMock = DiscoverServiceMock { _, _ in
            let result = DiscoverMovieResult(JSONString: json)!
            return self.scheduler.createColdObservable([.next(5, result), .completed(5)]).asSingle()
        }
        let coordinator = DiscoverResultsCoordinatorMock { _ in
            .never()
        }
        let genre = Genre(id: 101, name: "Test")
        let movieObserver = scheduler.createObserver(Movie?.self)
        let viewModel = DiscoverResultsViewModel(coordinator: coordinator,
                                                 genre: genre,
                                                 movieObserver: movieObserver.asObserver(),
                                                 discoverService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: DiscoverResultsViewModel.Input(ready: ready,
                                                                               selected: .never(),
                                                                               close: .never()))
        //3
        let loading = scheduler.createObserver(Bool.self)
        output.loading
            .drive(loading)
            .disposed(by: disposeBag)
        
        //4
        scheduler.start()
        //5
        XCTAssertEqual(loading.events, [
            .next(0, false),
            .next(10, true),
            .next(15, false)
        ])
    }
    
    func testError() {
        //1
        let serviceMock = DiscoverServiceMock { _, _ in
            self.scheduler.createColdObservable([.error(20, ServiceError.mappingFailed)]).asSingle()
        }
        let coordinator = DiscoverResultsCoordinatorMock { _ in
            .never()
        }
        let genre = Genre(id: 101, name: "Test")
        let movieObserver = scheduler.createObserver(Movie?.self)
        let viewModel = DiscoverResultsViewModel(coordinator: coordinator,
                                                 genre: genre,
                                                 movieObserver: movieObserver.asObserver(),
                                                 discoverService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: DiscoverResultsViewModel.Input(ready: ready,
                                                                               selected: .never(),
                                                                               close: .never()))
        //3
        let error = scheduler.createObserver(Bool.self)
        output.error
            .drive(error)
            .disposed(by: disposeBag)
        
        //4
        scheduler.start()
        //5
        XCTAssertEqual(error.events, [
            .next(0, false),
            .next(30, true)
        ])
    }
}

extension DiscoverResultItemViewModel: Equatable {
    public static func == (lhs: DiscoverResultItemViewModel, rhs: DiscoverResultItemViewModel) -> Bool {
        lhs.title == rhs.title
    }
}

struct DiscoverServiceMock: DiscoverServiceType {
    private var block: ([Int], Int) -> Single<DiscoverMovieResult>
    
    init(block: @escaping ([Int], Int) -> Single<DiscoverMovieResult>) {
        self.block = block
    }
    
    func discoverMovie(genreIds: [Int], page: Int) -> Single<DiscoverMovieResult> {
        block(genreIds, page)
    }
}

struct DiscoverResultsCoordinatorMock: DiscoverResultsCoordinatorType {
    private var block: (Int) -> Observable<MovieCoordinator.ResultType>
    
    init(block: @escaping (Int) -> Observable<MovieCoordinator.ResultType>) {
        self.block = block
    }
    
    func coordinateToMovieViewController(movieId: Int) -> Observable<MovieCoordinator.ResultType> {
        block(movieId)
    }
}

private let json: String = {
    guard let pathString = Bundle(for: DiscoverResultsViewModelTests.self).path(forResource: "DiscoverResultsViewModelTests", ofType: "json") else {
        fatalError("DiscoverResultsViewModelTests.json not found")
    }
    guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
        fatalError("Unable to convert DiscoverResultsViewModelTests.json to String")
    }
    return jsonString
}()
