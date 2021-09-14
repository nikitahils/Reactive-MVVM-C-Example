//
//  GetMoviesResult.swift
//  Core
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import ObjectMapper

public class GetMoviesResult: Mappable {
    public var id: Int?
    public var title: String?
    public var description: String?
    public var releaseDate: Date?
    
    public init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        id <- map["id", nested: false]
        title <- map["title", nested: false]
        description <- map["overview", nested: false]
        releaseDate <- (map["release_date", nested: false], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
    }
}
