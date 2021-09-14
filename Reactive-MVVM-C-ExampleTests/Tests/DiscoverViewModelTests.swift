//
//  DiscoverViewModelTests.swift
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

class DiscoverViewModelTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    func testGenreNotSelected() {
        //1
        let coordinator = DiscoverCoordinatorMock {
            self.scheduler.createColdObservable([.next(20, .cancel)]).asObservable()
        } toDiscoverResultsBlock: { _, _ in
            .never()
        }
        let viewModel = DiscoverViewModel(coordinator: coordinator)
        //2
        let genreTap = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: DiscoverViewModel.Input(genreTap: genreTap,
                                                                        discoverTap: .never(),
                                                                        close: .never()))
        //3
        let selectedGenre = scheduler.createObserver(Genre?.self)
        output.selectedGenre
            .drive(selectedGenre)
            .disposed(by: disposeBag)
        
        let selectedGenreTitle = scheduler.createObserver(String?.self)
        output.selectedGenreTitle
            .drive(selectedGenreTitle)
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(selectedGenre.events, [
            .next(0, nil),
            .next(30, nil)
        ])
        
        XCTAssertEqual(selectedGenreTitle.events, [
            .next(0, ""),
            .next(30, "")
        ])
    }
    
    func testGenreSelection() {
        //1
        let genre = Genre(id: 101, name: "Test")
        let coordinator = DiscoverCoordinatorMock {
            self.scheduler.createColdObservable([.next(20, .genreSelected(genre))]).asObservable()
        } toDiscoverResultsBlock: { _, _ in
            .never()
        }
        let viewModel = DiscoverViewModel(coordinator: coordinator)
        //2
        let genreTap = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: DiscoverViewModel.Input(genreTap: genreTap,
                                                                        discoverTap: .never(),
                                                                        close: .never()))
        //3
        let selectedGenre = scheduler.createObserver(Genre?.self)
        output.selectedGenre
            .drive(selectedGenre)
            .disposed(by: disposeBag)
        
        let selectedGenreTitle = scheduler.createObserver(String?.self)
        output.selectedGenreTitle
            .drive(selectedGenreTitle)
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(selectedGenre.events, [
            .next(0, nil),
            .next(30, genre)
        ])
        
        XCTAssertEqual(selectedGenreTitle.events, [
            .next(0, ""),
            .next(30, genre.name)
        ])
    }
    
    func testDiscoverTapsAvailable() {
        //1
        let genre = Genre(id: 101, name: "Test")
        let coordinator = DiscoverCoordinatorMock {
            self.scheduler.createColdObservable([.next(20, .genreSelected(genre))]).asObservable()
        } toDiscoverResultsBlock: { _, _ in
            .never()
        }
        let viewModel = DiscoverViewModel(coordinator: coordinator)
        //2
        let genreTap = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let output = viewModel.transform(input: DiscoverViewModel.Input(genreTap: genreTap,
                                                                        discoverTap: .never(),
                                                                        close: .never()))
        //3
        let discoverTapsAvailable = scheduler.createObserver(Bool.self)
        output.discoverTapsAvailable
            .drive(discoverTapsAvailable)
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(discoverTapsAvailable.events, [
            .next(0, false),
            .next(30, true)
        ])
    }
    
    func testMovieSelection() {
        //1
        let genre = Genre(id: 101, name: "Test")
        let movie = Movie(id: 102, title: "Test2", description: "Descr", releaseDate: Date())
        let coordinator = DiscoverCoordinatorMock {
            self.scheduler.createColdObservable([.next(10, .genreSelected(genre))]).asObservable()
        } toDiscoverResultsBlock: { genre, movieObserver in
            self.scheduler.scheduleAt(40) {
                movieObserver.onNext(movie)
            }
            return self.scheduler.createColdObservable([.next(10, ())]).asObservable()
        }
        let viewModel = DiscoverViewModel(coordinator: coordinator)
        //2
        let genreTap = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let discoverTap = scheduler.createColdObservable([.next(30, ())]).asObservable()
        let output = viewModel.transform(input: DiscoverViewModel.Input(genreTap: genreTap,
                                                                        discoverTap: discoverTap,
                                                                        close: .never()))
        //3
        let selectedMovie = scheduler.createObserver(Movie?.self)
        output.selectedMovie
            .drive(selectedMovie)
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(selectedMovie.events, [
            .next(0, nil),
            .next(40, movie)
        ])
    }
    
    func testDiscoverCoordinatorResult() {
        //1
        let genre = Genre(id: 101, name: "Test")
        let coordinator = DiscoverCoordinatorMock {
            self.scheduler.createColdObservable([.next(10, .genreSelected(genre))]).asObservable()
        } toDiscoverResultsBlock: { genre, movieObserver in
            return self.scheduler.createColdObservable([.next(10, ())]).asObservable()
        }
        let viewModel = DiscoverViewModel(coordinator: coordinator)
        //2
        let genreTap = scheduler.createColdObservable([.next(10, ())]).asObservable()
        let discoverTap = scheduler.createColdObservable([.next(30, ())]).asObservable()
        let output = viewModel.transform(input: DiscoverViewModel.Input(genreTap: genreTap,
                                                                        discoverTap: discoverTap,
                                                                        close: .never()))
        //3
        let discoverCoordinatorResult = scheduler.createObserver(VoidResult.self)
        output.discoverCoordinatorResult
            .drive(discoverCoordinatorResult)
            .disposed(by: disposeBag)
        //4
        scheduler.start()
        //5
        XCTAssertEqual(discoverCoordinatorResult.events, [
            .next(40, .void)
        ])
    }
    
}

struct DiscoverCoordinatorMock: DiscoverCoordinatorType {
    
    private var toGenresBlock: () -> Observable<GenresCoordinator.ResultType>
    private var toDiscoverResultsBlock: (Genre, AnyObserver<Movie?>) -> Observable<DiscoverResultsCoordinator.ResultType>
    
    init(toGenresBlock: @escaping () -> Observable<GenresCoordinator.ResultType>,
         toDiscoverResultsBlock: @escaping (Genre, AnyObserver<Movie?>) -> Observable<DiscoverResultsCoordinator.ResultType>
    ) {
        self.toGenresBlock = toGenresBlock
        self.toDiscoverResultsBlock = toDiscoverResultsBlock
    }
    
    func coordinateToGenresViewController() -> Observable<GenresCoordinator.ResultType> {
        toGenresBlock()
    }
    
    func coordinateToDiscoverResultsViewController(with genre: Genre, movieObserver: AnyObserver<Movie?>) -> Observable<DiscoverResultsCoordinator.ResultType> {
        toDiscoverResultsBlock(genre, movieObserver)
    }
}
