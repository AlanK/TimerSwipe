//
//  TableCell.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/25/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// Handle actions for the table view cell
protocol TableCellDelegate: AnyObject {
    /// Handle taps on the table view cell’s custom accessory view
    func cellButtonTapped(cell: TableCell)
}

/// Custom table view cell with heart icon accessory view
class TableCell: UITableViewCell {
    
    // MARK: Dependencies
    
    private weak var delegate: TableCellDelegate!
    
    // MARK: Initializers
    
    /**
     Sets up the cell with the standard layout.
     - parameter delegate: responsible for responding to taps on the favorite button
     - parameter timer: an `STSavedTimer` with a duration and a favorite status
     */
    func configure(delegate: TableCellDelegate, timer: STSavedTimer) {
        self.delegate = delegate
        
        let label = TableStrings.numberOfSeconds(Int(timer.seconds))
        
        // Configure based on isFavorite status
        let buttonImage = timer.isFavorite ? #imageLiteral(resourceName: "Full heart") : #imageLiteral(resourceName: "Empty heart")
        let accessLabel = timer.isFavorite ? label + ", " + TableStrings.isFavorite : label
        let buttonDescription = timer.isFavorite ? TableStrings.makeNotFavorite : TableStrings.makeFavorite
        
        // Set visible state of cell
        secondsLabel.text = label
        favoriteIcon.setImage(buttonImage.withRenderingMode(.alwaysTemplate), for: UIControlState())
        
        // Set accessibility state of cell
        let toggleFavorite = UIAccessibilityCustomAction.init(name: buttonDescription, target: self, selector: #selector(favoriteButton(_:)) )
        
        isAccessibilityElement = true
        accessibilityLabel = accessLabel
        accessibilityCustomActions = [toggleFavorite]
    }

    // MARK: Actions
    
    @IBAction func favoriteButton(_ sender: UIButton) { delegate.cellButtonTapped(cell: self) }
    
    // MARK: Outlets
    
    @IBOutlet var secondsLabel: UILabel!
    @IBOutlet var favoriteIcon: UIButton!
}
