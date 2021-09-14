//
//  GenreViewModel.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 31.08.2021.
//

import Foundation

class GenreItemViewModel {
    
    let title: String
    
    init(_ genre: Genre) {
        self.title = genre.name
    }
    
}
