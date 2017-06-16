//
//  STTableViewCell.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/25/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// Handle actions for the table view cell
protocol STTableViewCellDelegate {
    /// Handle taps on the table view cell’s custom accessory view
    func cellButtonTapped(cell: STTableViewCell)
}

/// Custom table view cell with heart icon accessory view
class STTableViewCell: UITableViewCell {
    /// Table view cell delegate
    var delegate: STTableViewCellDelegate?
    
    // MARK: Properties
    
    /// Text label
    @IBOutlet var secondsLabel: UILabel!
    /// Heart icon button
    @IBOutlet var favoriteIcon: UIButton!
    
    // MARK: Actions
    
    @IBAction func favoriteButton(_ sender: UIButton) {
        delegate?.cellButtonTapped(cell: self)
    }

    // MARK: Setup
    
    /// Do layout on the cell
    func setupCell(with timer: STSavedTimer) {
        secondsLabel.text = String(timer.centiseconds/K.centisecondsPerSecond) + " seconds"
        secondsLabel.accessibilityTraits = UIAccessibilityTraitButton
        
        favoriteIcon.accessibilityLabel = "Favorite"
        // Set heart icon based on isFavorite
        switch timer.isFavorite {
        case true:
            favoriteIcon.setImage(UIImage(named: K.fullHeart)?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            favoriteIcon.accessibilityValue = "On"
        case false:
            favoriteIcon.setImage(UIImage(named: K.emptyHeart)?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            favoriteIcon.accessibilityValue = "Off"
        }
    }
}
