//
//  STTableViewCell.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/25/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STTableViewCell: UITableViewCell {

    // MARK: Properties
    
    var containingTable: STTableViewController?
    var tapAction: ((UITableViewCell) -> Void)?
    
    @IBOutlet var secondsLabel: UILabel!
    @IBOutlet var favoriteIcon: UIButton!
    
    @IBAction func favoriteButton(_ sender: UIButton) {
        tapAction?(self)
        print(secondsLabel.text!)

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
