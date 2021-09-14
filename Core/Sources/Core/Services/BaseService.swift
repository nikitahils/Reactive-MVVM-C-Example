//
//  BaseService.swift
//  Core
//
//  Created by Nikita Tolkachev on 30.08.2021.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import ObjectMapper

public enum ServiceError: Error {
    case mappingFailed
}

open class BaseService {
    
    private static var apiKey = "7e578c50ed288616f15ca3c86d45c03f"
    private static var baseURLString = "https://api.themoviedb.org/3/"
    
    public init() {}
    
    func get<T: BaseMappable>(from resourcePath: String, with parameters: BaseMappable? = nil) -> Single<T> {
        var allParameters: [String: Any] = ["api_key": Self.apiKey]
        
        if let parameters = parameters {
            allParameters.merge(parameters.toJSON(), uniquingKeysWith: { l, r in l })
        }

        return RxAlamofire.json(.get, Self.baseURLString + resourcePath,
                                parameters: allParameters,
                                encoding: URLEncoding.queryString,
                                headers: nil)
            .map { result -> T in
                if let dict = result as? [String: Any],
                   let result = Mapper<T>().map(JSONObject: dict)
                {
                    return result
                }
                
                throw ServiceError.mappingFailed
            }.asSingle()
    }
    
}
