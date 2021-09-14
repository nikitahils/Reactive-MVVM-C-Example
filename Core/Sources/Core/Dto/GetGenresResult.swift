//
//  GetGenresResult.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import ObjectMapper

public class GenreResult: Mappable {
    public var id: Int?
    public var name: String?
    
    public init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        id <- map["id", nested: false]
        name <- map["name", nested: false]
    }
}

public class GetGenresResult: Mappable {
    public var genres: [GenreResult]?
    
    public init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        genres <- map["genres", nested: false]
    }
}
