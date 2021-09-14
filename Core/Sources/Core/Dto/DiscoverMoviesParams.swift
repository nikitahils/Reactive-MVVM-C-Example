//
//  DiscoverMoviesParams.swift
//  Core
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import ObjectMapper

public class DiscoverMoviesParams: Mappable {
    public var page: Int?
    public var genreIds: [Int]?
    
    init(page: Int, genreIds: [Int]) {
        self.page = page
        self.genreIds = genreIds
    }
    
    public init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        let genreIdsTransform = TransformOf<[Int], String>(fromJSON: { (value: String?) -> [Int]? in
            return nil
        }, toJSON: { (values: [Int]?) -> String? in
            guard let values = values else { return nil }
            var result = ""
            for index in 0..<max(values.count - 1, 0) {
                result += "\(values[index]),"
            }
            if let last = values.last {
                result += "\(last)"
            }
            return result
        })
        
        genreIds <- (map["with_genres", nested: false], genreIdsTransform)
        page <- map["page", nested: false]
    }
}
