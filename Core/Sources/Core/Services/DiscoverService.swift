//
//  DiscoverService.swift
//  Core
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import RxSwift
import RxAlamofire

public protocol DiscoverServiceType {
    func discoverMovie(genreIds: [Int], page: Int) -> Single<DiscoverMovieResult>
}

public class DiscoverService: BaseService, DiscoverServiceType {
    
    public static var instance = DiscoverService()
    
    public func discoverMovie(genreIds: [Int], page: Int) -> Single<DiscoverMovieResult> {
        get(from: "discover/movie", with: DiscoverMoviesParams(page: page, genreIds: genreIds))
    }
    
}
