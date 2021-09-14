//
//  MovieViewModel.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 06.09.2021.
//

import Foundation
import Core
import RxSwift
import RxCocoa

class MovieViewModel: ViewModelType {
    
    struct Input {
        let ready: Observable<Void>
        let close: Observable<Void>
    }
    
    struct Output {
        let loading: Driver<Bool>
        let error: Driver<Bool>
        let movie: Driver<Movie?>
        let title: Driver<String>
        let description: Driver<String>
        let releaseDate: Driver<String>
        let close: Observable<Void>
    }
    
    private let loadingSubject = BehaviorSubject<Bool>(value: false)
    private let errorSubject = BehaviorSubject<Bool>(value: false)
    private let movieId: Int
    private let moviesService: MoviesServiceType
    
    init(movieId: Int, moviesService: MoviesServiceType = MoviesService.instance) {
        self.movieId = movieId
        self.moviesService = moviesService
    }
    
    func transform(input: Input) -> Output {
        let movie = input.ready
            .take(1)
            .flatMap { [moviesService, movieId, errorSubject, loadingSubject] _ in
                moviesService.movie(id: movieId)
                    .do(onError: { _ in
                        errorSubject.onNext(true)
                    }, onSubscribe: {
                        loadingSubject.onNext(true)
                    }, onDispose: {
                        loadingSubject.onNext(false)
                    })
            }
            .map { result -> Movie? in
                guard let id = result.id, let title = result.title else { return nil }
                let movie = Movie(id: id, title: title, description: result.description, releaseDate: result.releaseDate)
                return movie
            }
            .startWith(nil)
            .asDriver(onErrorJustReturn: nil)
        
        let title = movie
            .map { $0?.title ?? "" }
            .asDriver(onErrorJustReturn: "")
        
        let description = movie
            .map { $0?.description ?? "" }
            .asDriver(onErrorJustReturn: "")
        
        let releaseDate = movie
            .map { $0?.releaseDate == nil ? "" : String(describing: $0!.releaseDate!) }
            .asDriver(onErrorJustReturn: "")
        
        let loading = loadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let error = errorSubject
            .asDriver(onErrorJustReturn: true)
        
        let close = input.close
        
        return Output(loading: loading,
                      error: error,
                      movie: movie,
                      title: title,
                      description: description,
                      releaseDate: releaseDate,
                      close: close)
    }
    
}
