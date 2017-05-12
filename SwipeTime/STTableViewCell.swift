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
}
