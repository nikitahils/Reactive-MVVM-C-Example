//
//  DiscoverResultItemViewModel.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 02.09.2021.
//

import Foundation

class DiscoverResultItemViewModel {
    
    let title: String
    
    init(_ movie: Movie) {
        self.title = movie.title
    }
    
}
