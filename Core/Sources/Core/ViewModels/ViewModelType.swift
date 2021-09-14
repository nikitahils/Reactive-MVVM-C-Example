//
//  ViewModelType.swift
//  Core
//
//  Created by Nikita Tolkachev on 01.09.2021.
//

import Foundation

public protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
