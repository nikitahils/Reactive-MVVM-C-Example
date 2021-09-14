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

class MovieViewModelTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    func testMovie() {
        //1
        let serviceMock = MoviesServiceMock { _ in
            let result = GetMoviesResult(JSONString: json)!
            return self.scheduler.createColdObservable([.next(5, result), .completed(5)]).asSingle()
        }
        let viewModel = MovieViewModel(movieId: jsonMovieId, moviesService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: MovieViewModel.Input(ready: ready,
                                                                      close: .never()))
        //3
        let title = scheduler.createObserver(String.self)
        output.title
            .drive(title)
            .disposed(by: disposeBag)
        
        let description = scheduler.createObserver(String.self)
        output.description
            .drive(description)
            .disposed(by: disposeBag)
        
        let releaseDate = scheduler.createObserver(String.self)
        output.releaseDate
            .drive(releaseDate)
            .disposed(by: disposeBag)
        
        let movie = scheduler.createObserver(Movie?.self)
        output.movie
            .drive(movie)
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(title.events, [
            .next(0, ""),
            .next(15, jsonTitle),
            .completed(15)
        ])
        
        XCTAssertEqual(description.events, [
            .next(0, ""),
            .next(15, jsonDescription),
            .completed(15)
        ])
        
        XCTAssertEqual(releaseDate.events, [
            .next(0, ""),
            .next(15, jsonReleaseDate),
            .completed(15)
        ])
        
        XCTAssertEqual(movie.events, [
            .next(0, nil),
            .next(15, jsonMovie),
            .completed(15)
        ])
    }

    func testError() {
        //1
        let serviceMock = MoviesServiceMock { _ in
            self.scheduler.createColdObservable([.error(20, ServiceError.mappingFailed)]).asSingle()
        }
        let viewModel = MovieViewModel(movieId: jsonMovieId, moviesService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: MovieViewModel.Input(ready: ready,
                                                                     close: .never()))
        //3
        let error = scheduler.createObserver(Bool.self)
        output.error
            .drive(error)
            .disposed(by: disposeBag)
        
        output.movie
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
        let serviceMock = MoviesServiceMock { _ in
            let result = GetMoviesResult(JSONString: json)!
            return self.scheduler.createColdObservable([.next(10, result), .completed(10)]).asSingle()
        }
        let viewModel = MovieViewModel(movieId: jsonMovieId, moviesService: serviceMock)
        //2
        let ready = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: MovieViewModel.Input(ready: ready,
                                                                      close: .never()))
        //3
        let loading = scheduler.createObserver(Bool.self)
        output.loading
            .drive(loading)
            .disposed(by: disposeBag)

        output.movie
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

extension Movie: Equatable {
    public static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}

struct MoviesServiceMock: MoviesServiceType {
    private var block: (Int) -> Single<GetMoviesResult>
    
    init(block: @escaping (Int) -> Single<GetMoviesResult>) {
        self.block = block
    }
    
    func movie(id: Int) -> Single<GetMoviesResult> {
        block(id)
    }
}

private let jsonMovieId = 359724
private let jsonTitle = "Ford v Ferrari"
private let jsonDescription = "American car designer Carroll Shelby and the British-born driver Ken Miles work together to battle corporate interference, the laws of physics, and their own personal demons to build a revolutionary race car for Ford Motor Company and take on the dominating race cars of Enzo Ferrari at the 24 Hours of Le Mans in France in 1966."
private let dateFormatter = DateFormatter(withFormat: "YYYY-MM-dd", locale: "en_US")
private let jsonReleaseDate: String = {
    let date = dateFormatter.date(from: "2019-11-13")!
    return String(describing: date)
}()
private let jsonMovie = Movie(id: 359724,
                      title: jsonTitle,
                      description: jsonDescription,
                      releaseDate: dateFormatter.date(from: "2019-11-13")!)

private let json: String = {
    guard let pathString = Bundle(for: MovieViewModelTests.self).path(forResource: "MovieViewModelTests", ofType: "json") else {
        fatalError("MovieViewModelTests.json not found")
    }
    guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
        fatalError("Unable to convert MovieViewModelTests.json to String")
    }
    return jsonString
}()
