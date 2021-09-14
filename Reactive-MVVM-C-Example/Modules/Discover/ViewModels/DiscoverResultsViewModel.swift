//
//  DiscoverResultsViewModel.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 02.09.2021.
//

import Foundation
import Core
import RxSwift
import RxCocoa

class DiscoverResultsViewModel: ViewModelType {
    
    struct Input {
        let ready: Observable<Void>
        let selected: Observable<IndexPath>
        let close: Observable<Void>
    }
    
    struct Output {
        let loading: Driver<Bool>
        let error: Driver<Bool>
        let results: Driver<[DiscoverResultItemViewModel]>
        let movieCoordinatorResult: Driver<VoidResult>
        let close: Observable<Void>
    }
    
    private let loadingSubject = BehaviorSubject(value: false)
    private let errorSubject = BehaviorSubject<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    private let discoverService: DiscoverServiceType
    private let genre: Genre
    private let coordinator: DiscoverResultsCoordinatorType
    private let movieObserver: AnyObserver<Movie?>
    
    init(coordinator: DiscoverResultsCoordinatorType, genre: Genre, movieObserver: AnyObserver<Movie?>, discoverService: DiscoverServiceType = DiscoverService.instance) {
        self.genre = genre
        self.coordinator = coordinator
        self.discoverService = discoverService
        self.movieObserver = movieObserver
    }
    
    func transform(input: Input) -> Output {
        let movies = input.ready
            .take(1)
            .flatMap { [discoverService, genre, errorSubject, loadingSubject] in
                discoverService.discoverMovie(genreIds: [genre.id], page: 1)
                    .do(onError: { _ in
                        errorSubject.onNext(true)
                    }, onSubscribe: {
                        loadingSubject.onNext(true)
                    }, onDispose: {
                        loadingSubject.onNext(false)
                    })
            }
            .map {
                $0.results?.compactMap { result in
                    guard let id = result.id, let title = result.title else {
                        return nil
                    }
                    return Movie(id: id, title: title)
                } ?? [Movie]()
            }
            .share()
        
        let viewModels = movies
            .map {
                $0.map(DiscoverResultItemViewModel.init)
            }
            .asDriver(onErrorJustReturn: [])
        
        let error = errorSubject
            .asDriver(onErrorJustReturn: true)
        
        let loading = loadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let movie = input.selected
            .withLatestFrom(movies) { $1.count > $0.item ? $1[$0.item] : nil }
            .filter { $0 != nil }
            .map { $0! }
        
        movie
            .bind(to: movieObserver)
            .disposed(by: disposeBag)
        
        let movieCoordinatorResult =  movie
            .flatMap { [coordinator] movie in
                coordinator.coordinateToMovieViewController(movieId: movie.id)
            }
            .map { _ in VoidResult.void }
            .asDriver(onErrorJustReturn: .void)
        
        movieCoordinatorResult
            .drive()
            .disposed(by: disposeBag)
        
        let close = input.close

        return Output(loading: loading,
                      error: error,
                      results: viewModels,
                      movieCoordinatorResult: movieCoordinatorResult,
                      close: close)
    }
    
}
