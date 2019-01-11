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
    private let tableView: UITableView
    
    // MARK: Initializers
    
    init(_ vc: ListController, model: Model, tableView: UITableView) {
        self.vc = vc
        self.model = model
        self.tableView = tableView
        super.init()
    }
    
    // MARK: Properties
    
    var canEdit: Bool { return model.count > 0 }
    
    private let numberOfSections = 1, currentSection = 0
    
    // MARK: Methods
    
    func saveState() { model.saveData() }
    
    func addTimer(seconds: TimeInterval) {
        let timer = STSavedTimer(seconds: seconds)
        model.append(timer: timer)
        model.saveData()
        tableView.insertRows(at: [IndexPath(row: model.count - 1, section: currentSection)], with: .automatic)
        vc.refreshEditButton()
    }
}

// MARK: - Data Source

extension ListDataSourceAndDelegate: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { return numberOfSections }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return model.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STTableViewCell", for: indexPath) as! TableCell
        // Pass delegate and timer to cell so it can complete its own setup
        cell.configure(delegate: self, timer: model[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Don't delete the row if the model can't be updated
        guard editingStyle == .delete else { return }
        _ = model.remove(at: indexPath.row)
        model.saveData()
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        vc.refreshEditButton()

        switch model.count {
        case 0:
            
            // You shouldn't toggle setEditing within this method, so GCD to the rescue
            let nearFuture = DispatchTime.now() + K.editButtonDelay
            let finishEditing = DispatchWorkItem { [unowned self] in
                self.vc.setEditing(false, animated: false)
            }
            
            DispatchQueue.main.asyncAfter(deadline: nearFuture, execute: finishEditing)
            
        default:
            
            let newIndexPath = indexPath.row == 0 ? indexPath : IndexPath(row: indexPath.row - 1, section: currentSection)
            let cell = tableView.cellForRow(at: newIndexPath)
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: cell)
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
        guard let index = tableView.indexPath(for: cell)?.row else { return }
        
        // Update favorite timer and save
        let rowsToUpdate = model.updateFavorite(at: index)
        model.saveData()
        
        // Update the table view
        let indexPaths = rowsToUpdate.map { IndexPath(row: $0, section: currentSection) }
        tableView.reloadRows(at: indexPaths, with: .none)
    }
}
