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
    
    private unowned let vc: ListController
    private let model: Model
    
    // MARK: Initializers
    
    init(_ vc: ListController, model: Model) {
        self.vc = vc
        self.model = model
        super.init()
    }
}

// MARK: - Data Source

extension ListDataSourceAndDelegate: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return model.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STTableViewCell", for: indexPath)
        // Pass delegate and timer to cell so it can complete its own setup
        if let cell = cell as? TableCell {
            cell.setupCell(delegate: self, timer: model[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Don't delete the row if the model can't be updated
        guard editingStyle == .delete else { return }
        let _ = model.remove(at: indexPath.row)
        model.saveData()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        vc.refreshEditButton()
        // You shouldn't toggle setEditing within this method, so GCD to the rescue
        if model.count == 0 {
            let nearFuture = DispatchTime.now() + K.editButtonDelay
            let work = DispatchWorkItem {
                self.vc.setEditing(false, animated: false)
            }
            DispatchQueue.main.asyncAfter(deadline: nearFuture, execute: work)
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, vc.addButton)
        } else {
            let newIndexPath = (indexPath.row == 0) ? indexPath : IndexPath.init(row: indexPath.row - 1, section: 0)
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tableView.cellForRow(at: newIndexPath))
        }
    }
}

// MARK: - TableCellDelegate

extension ListDataSourceAndDelegate: TableCellDelegate {
    func cellButtonTapped(cell: TableCell) {
        
        // TODO: Implement this
        
    }
}
