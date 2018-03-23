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
    
    // MARK: Properties
    
    var canEdit: Bool { return model.count > 0 }
    
    // MARK: Methods
    
    func saveState() { model.saveData() }
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
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let timer = model.remove(at: fromIndexPath.row)
        model.insert(timer, at: toIndexPath.row)
        model.saveData()
    }
}

// MARK: - Table View Delegate

extension ListDataSourceAndDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let timer = model[indexPath.row]
        vc.didSelect(timer)
    }
}

// MARK: - TableCellDelegate

extension ListDataSourceAndDelegate: TableCellDelegate {
    
    func cellButtonTapped(cell: TableCell) {
        guard let index = vc.tableView.indexPath(for: cell)?.row else { return }
        
        // Update favorite timer and save
        let rowsToUpdate = model.updateFavorite(at: index)
        model.saveData()
        
        // Update the table view
        let indexPaths = rowsToUpdate.map { IndexPath(row: $0, section: 0) }
        vc.tableView.reloadRows(at: indexPaths, with: .none)
    }
}
