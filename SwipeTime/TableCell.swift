//
//  TableCell.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/25/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// Handle actions for the table view cell
protocol TableCellDelegate {
    /// Handle taps on the table view cell’s custom accessory view
    func cellButtonTapped(cell: TableCell)
}

/// Custom table view cell with heart icon accessory view
class TableCell: UITableViewCell {
    /// Table view cell delegate
    var delegate: TableCellDelegate?
    
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
        secondsLabel.text = NSLocalizedString("numberOfSeconts", value: "\(timer.centiseconds/K.centisecondsPerSecond) seconds", comment: "{whole number} seconds")
        secondsLabel.accessibilityTraits = UIAccessibilityTraitButton
        
        favoriteIcon.accessibilityLabel = NSLocalizedString("favButton", value: "Favorite", comment: "Will be marked on or off to indicate whether or not an item is the user’s favorite")
        // Set heart icon based on isFavorite
        switch timer.isFavorite {
        case true:
            favoriteIcon.setImage(UIImage(named: K.fullHeart)?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            favoriteIcon.accessibilityValue = NSLocalizedString("switchOn", value: "On", comment: "An on/off switch in the on position")
        case false:
            favoriteIcon.setImage(UIImage(named: K.emptyHeart)?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            favoriteIcon.accessibilityValue = NSLocalizedString("switchOff", value: "Off", comment: "An on/off switch in the off position")
        }
    }
}
