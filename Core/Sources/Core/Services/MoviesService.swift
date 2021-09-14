//
//  MoviesService.swift
//  Core
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import RxSwift
import RxAlamofire

public protocol MoviesServiceType {
    func movie(id: Int) -> Single<GetMoviesResult>
}

public class MoviesService: BaseService, MoviesServiceType {
    
    public static var instance = MoviesService()
    
    public func movie(id: Int) -> Single<GetMoviesResult> {
        get(from: "movie/\(id)")
    }
    
}
