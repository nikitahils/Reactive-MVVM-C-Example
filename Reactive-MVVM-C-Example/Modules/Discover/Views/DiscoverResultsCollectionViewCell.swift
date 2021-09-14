//
//  DiscoverResultsCollectionViewCell.swift
//  Reactive-MVVM-Test
//
//  Created by Nikita Tolkachev on 02.09.2021.
//

import Foundation
import UIKit

class DiscoverResultsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    var viewModel: DiscoverResultItemViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
        }
    }
}
