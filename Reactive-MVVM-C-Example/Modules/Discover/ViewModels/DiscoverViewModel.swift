//
//  DiscoverViewModel.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import Core
import RxSwift
import RxCocoa

class DiscoverViewModel: ViewModelType {
    
    struct Input {
        let genreTap: Observable<Void>
        let discoverTap: Observable<Void>
        let close: Observable<Void>
    }
    
    struct Output {
        let selectedGenreTitle: Driver<String>
        let selectedGenre: Driver<Genre?>
        let selectedMovieTitle: Driver<String>
        let selectedMovie: Driver<Movie?>
        let discoverTapsAvailable: Driver<Bool>
        let discoverCoordinatorResult: Driver<VoidResult>
        let close: Observable<Void>
    }
    
    private let disposeBag = DisposeBag()
    
    private let coordinator: DiscoverCoordinatorType
    private let movieSubject: BehaviorSubject<Movie?>
    
    init(coordinator: DiscoverCoordinatorType, movieSubject: BehaviorSubject<Movie?>? = nil) {
        self.coordinator = coordinator
        self.movieSubject = movieSubject ?? BehaviorSubject<Movie?>(value: nil)
    }
    
    func transform(input: Input) -> Output {
        let selectedGenre = input.genreTap
            .flatMap { [coordinator] _ in
                coordinator.coordinateToGenresViewController()
            }
            .map(\GenresCoordinator.Result.genre)
            .startWith(nil)
            .asDriver(onErrorJustReturn: nil)
        
        let selectedGenreTitle = selectedGenre
            .map { $0?.name ?? "" }
        
        let discoverTapsAvailable = selectedGenre
            .map { $0 != nil }
        
        let discoverTransition = input.discoverTap
            .withLatestFrom(selectedGenre) { $1 }
            .filter { $0 != nil }
            .map { $0! }
        
        let selectedMovie = movieSubject
            .asDriver(onErrorJustReturn: nil)
        let selectedMovieTitle = selectedMovie
            .map { $0?.title ?? "" }
        let selectedMovieObserver = movieSubject
            .asObserver() as AnyObserver
        let discoverResult = discoverTransition
            .flatMap { [coordinator] genre in
                coordinator.coordinateToDiscoverResultsViewController(with: genre,
                                                                      movieObserver: selectedMovieObserver)
            }
            .map { _ in VoidResult.void }
            .asDriver(onErrorJustReturn: .void)
        discoverResult
            .drive()
            .disposed(by: disposeBag)
        
        let close = input.close
        
        return Output(selectedGenreTitle: selectedGenreTitle,
                      selectedGenre: selectedGenre,
                      selectedMovieTitle: selectedMovieTitle,
                      selectedMovie: selectedMovie,
                      discoverTapsAvailable: discoverTapsAvailable,
                      discoverCoordinatorResult: discoverResult,
                      close: close)
    }
}
