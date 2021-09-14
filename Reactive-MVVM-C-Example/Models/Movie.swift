//
//  Movie.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 02.09.2021.
//

import Foundation

class Movie {
    let id: Int
    let title: String
    var description: String?
    var releaseDate: Date?
    
    init(id: Int, title: String, description: String? = nil, releaseDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.releaseDate = releaseDate
    }
}
