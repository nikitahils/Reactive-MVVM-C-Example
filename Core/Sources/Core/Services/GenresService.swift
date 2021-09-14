//
//  GenresService.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import RxSwift
import RxAlamofire

public protocol GenresServiceType {
    func genres() -> Single<GetGenresResult>
}

public class GenresService: BaseService, GenresServiceType {
    
    public static var instance = GenresService()
    
    public func genres() -> Single<GetGenresResult> {
        get(from: "genre/movie/list")
    }
    
}
