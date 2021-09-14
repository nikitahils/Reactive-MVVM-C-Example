//
//  GenresViewModelTests.swift
//  Reactive-MVVM-TestTests
//
//  Created by Nikita Tolkachev on 06.09.2021.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
import Core
@testable import Reactive_MVVM_C_Example

class GenresViewModelTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    func testGenreResults() {
        //1
        let serviceMock = GenresServiceMock {
            let result = GetGenresResult(JSONString: json)!
            return self.scheduler.createColdObservable([.next(5, result), .completed(5)]).asSingle()
        }
        let viewModel = GenresViewModel(genresService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: GenresViewModel.Input(ready: ready,
                                                                      close: .never(),
                                                                      selected: .never()))
        //3
        let results = scheduler.createObserver([GenreItemViewModel].self)
        output.results
            .drive(results)
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(results.events, [
            .next(15, [GenreItemViewModel(Genre(id: 28, name: "Action")),
                       GenreItemViewModel(Genre(id: 12, name: "Adventure")),
                       GenreItemViewModel(Genre(id: 16, name: "Animation")),
                       GenreItemViewModel(Genre(id: 35, name: "Comedy")),
                       GenreItemViewModel(Genre(id: 80, name: "Crime")),
                       GenreItemViewModel(Genre(id: 99, name: "Documentary")),
                       GenreItemViewModel(Genre(id: 18, name: "Drama")),
                       GenreItemViewModel(Genre(id: 10751, name: "Family")),
                       GenreItemViewModel(Genre(id: 14, name: "Fantasy")),
                       GenreItemViewModel(Genre(id: 36, name: "History")),
                       GenreItemViewModel(Genre(id: 27, name: "Horror")),
                       GenreItemViewModel(Genre(id: 10402, name: "Music")),
                       GenreItemViewModel(Genre(id: 9648, name: "Mystery"))]),
            .completed(15)
        ])
    }
    
    func testGenreSelection() {
        //1
        let serviceMock = GenresServiceMock {
            let result = GetGenresResult(JSONString: json)!
            return self.scheduler.createColdObservable([.next(5, result), .completed(5)]).asSingle()
        }
        let viewModel = GenresViewModel(genresService: serviceMock)
        //2
        let selected = scheduler.createColdObservable([.next(10, IndexPath(item: 0, section: 0)),
                                                       .next(20, IndexPath(item: 2, section: 0)),
                                                       .next(30, IndexPath(item: 5, section: 0))])
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: GenresViewModel.Input(ready: ready,
                                                                      close: .never(),
                                                                      selected: selected.asObservable()))
        //3
        let selectedGenre = scheduler.createObserver(Genre.self)
        output.selected
            .bind(to: selectedGenre)
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(selectedGenre.events, [
            .next(20, Genre(id: 16, name: "Animation")),
            .next(30, Genre(id: 99, name: "Documentary"))
        ])
    }

    func testError() {
        //1
        let serviceMock = GenresServiceMock {
            self.scheduler.createColdObservable([.error(20, ServiceError.mappingFailed)]).asSingle()
        }
        let viewModel = GenresViewModel(genresService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: GenresViewModel.Input(ready: ready,
                                                                      close: .never(),
                                                                      selected: .never()))
        //3
        let error = scheduler.createObserver(Bool.self)
        output.error
            .drive(error)
            .disposed(by: disposeBag)
        
        output.results
            .drive()
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(error.events, [
            .next(0, false),
            .next(30, true),
        ])
    }
    
    func testLoading() {
        //1
        let serviceMock = GenresServiceMock {
            let result = GetGenresResult(JSONString: json)!
            return self.scheduler.createColdObservable([.next(10, result), .completed(10)]).asSingle()
        }
        let viewModel = GenresViewModel(genresService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: GenresViewModel.Input(ready: ready,
                                                                      close: .never(),
                                                                      selected: .never()))
        //3
        let loading = scheduler.createObserver(Bool.self)
        output.loading
            .drive(loading)
            .disposed(by: disposeBag)
        
        output.results
            .drive()
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(loading.events, [
            .next(0, false),
            .next(10, true),
            .next(20, false),
        ])
    }

}

extension Genre: Equatable {
    public static func == (lhs: Genre, rhs: Genre) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}

extension GenreItemViewModel: Equatable {
    public static func == (lhs: GenreItemViewModel, rhs: GenreItemViewModel) -> Bool {
        lhs.title == rhs.title
    }
}

struct GenresServiceMock: GenresServiceType {
    
    private var block: () -> Single<GetGenresResult>
    
    init(genresBlock: @escaping () -> Single<GetGenresResult>) {
        self.block = genresBlock
    }
    
    func genres() -> Single<GetGenresResult> {
        block()
    }
}

private let json: String = {
    guard let pathString = Bundle(for: GenresViewModelTests.self).path(forResource: "GenresViewModelTests", ofType: "json") else {
        fatalError("GenresViewModelTests.json not found")
    }
    guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
        fatalError("Unable to convert GenresViewModelTests.json to String")
    }
    return jsonString
}()
