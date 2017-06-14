//
//  STTableViewCell.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/25/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

protocol STTableViewCellDelegate {
    func cellButtonTapped(cell: STTableViewCell)
}

class STTableViewCell: UITableViewCell {
    var delegate: STTableViewCellDelegate?
    
    // MARK: Properties
    
    @IBOutlet var secondsLabel: UILabel!
    @IBOutlet var favoriteIcon: UIButton!
    
    // MARK: Actions
    
    @IBAction func favoriteButton(_ sender: UIButton) {
        delegate?.cellButtonTapped(cell: self)
    }

    // MARK: Setup
    
    func setupCell(with timer: STSavedTimer) {
        self.secondsLabel.text = String(timer.centiseconds/100) + " seconds"
        
        self.secondsLabel.accessibilityTraits = UIAccessibilityTraitButton
        self.favoriteIcon.accessibilityLabel = "Favorite"
        
        switch timer.isFavorite {
        case true:
            self.favoriteIcon.setImage(UIImage(named: "Full heart")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            self.favoriteIcon.accessibilityValue = "On"
        case false:
            self.favoriteIcon.setImage(UIImage(named: "Empty heart")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            self.favoriteIcon.accessibilityValue = "Off"
}
    }
}
