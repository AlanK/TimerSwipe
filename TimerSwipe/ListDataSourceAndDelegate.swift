//
//  ListDataSourceAndDelegate.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/23/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

class ListDataSourceAndDelegate: NSObject {
    // MARK: Dependencies
    
    private let model: Model
    
    // MARK: Initializers
    
    init(_ model: Model) {
        self.model = model
        super.init()
    }
}

// MARK: - Data Source

extension ListDataSourceAndDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return model.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STTableViewCell", for: indexPath)
        // Pass delegate and timer to cell so it can complete its own setup
        if let cell = cell as? TableCell {
            cell.setupCell(delegate: self, timer: model[indexPath.row])
        }
        return cell
    }
}

// MARK: - TableCellDelegate

extension ListDataSourceAndDelegate: TableCellDelegate {
    func cellButtonTapped(cell: TableCell) {
        
        // TODO: Implement this
        
    }
}
