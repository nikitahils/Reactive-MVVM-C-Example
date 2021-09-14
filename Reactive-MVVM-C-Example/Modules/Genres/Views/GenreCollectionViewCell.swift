//
//  GenreCollectionViewCell.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 31.08.2021.
//

import Foundation
import UIKit

class GenreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    public var viewModel: GenreItemViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
        }
    }
    
}
