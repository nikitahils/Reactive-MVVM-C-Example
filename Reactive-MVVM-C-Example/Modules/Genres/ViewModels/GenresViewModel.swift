//
//  GenresViewModel.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import RxSwift
import RxCocoa
import Core

class GenresViewModel: ViewModelType {
    
    struct Input {
        let ready: Observable<Void>
        let close: Observable<Void>
        let selected: Observable<IndexPath>
    }
    
    struct Output {
        let loading: Driver<Bool>
        let error: Driver<Bool>
        let results: Driver<[GenreItemViewModel]>
        let close: Observable<Void>
        let selected: Observable<Genre>
    }
    
    private let loadingSubject = BehaviorSubject<Bool>(value: false)
    private let errorSubject = BehaviorSubject<Bool>(value: false)
    private let genresService: GenresServiceType
    
    init(genresService: GenresServiceType = GenresService.instance) {
        self.genresService = genresService
    }
    
    func transform(input: Input) -> Output {
        let genres = input.ready
            .take(1)
            .flatMap { [genresService, errorSubject, loadingSubject] in
                genresService.genres()
                    .do(onError: { [] _ in
                        errorSubject.onNext(true)
                    }, onSubscribe: {
                        loadingSubject.onNext(true)
                    }, onDispose: {
                        loadingSubject.onNext(false)
                    })
            }
            .map {
                $0.genres?.compactMap({
                    guard let id = $0.id, let name = $0.name else {
                        return nil
                    }
                    return Genre(id: id, name: name)
                }) ?? [Genre]()
            }
            .share()
        
        let loading = loadingSubject
            .asDriver(onErrorJustReturn: false)
        
        let error = errorSubject
            .asDriver(onErrorJustReturn: true)
        
        let results = genres
            .map {
                $0.map(GenreItemViewModel.init)
            }
            .asDriver(onErrorJustReturn: [])

        let selected = input.selected
            .withLatestFrom(genres) { $1.count > $0.item ? $1[$0.item] : nil }
            .filter { $0 != nil }
            .map { $0! }
        
        let close = input.close
        
        return Output(loading: loading,
                      error: error,
                      results: results,
                      close: close,
                      selected: selected)
    }

}
