//
//  DiscoverMovieResult.swift
//  Core
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import ObjectMapper

public class DiscoverMovieResult: Mappable {
    public var page: Int?
    public var results: [GetMoviesResult]?
    public var totalPages: Int?
    public var totalResults: Int?
    
    public init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        page <- map["page", nested: false]
        results <- map["results", nested: false]
        totalPages <- map["total_pages", nested: false]
        totalResults <- map["total_results", nested: false]
    }
}
