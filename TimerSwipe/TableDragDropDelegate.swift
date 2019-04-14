//
//  TableDragDropDelegate.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 12/17/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

protocol TableModelDragDropDelegate: NSObjectProtocol {
    func updateModelOnDrop(_ sourcePaths: [IndexPath], targetIndexPath: IndexPath) -> Bool
}

class TableDragDropDelegate: NSObject {
    private unowned let tableViewDataSource: UITableViewDataSource
    private unowned let tableModelDragDropDelegate: TableModelDragDropDelegate
    
    init(_ tableViewDataSource: UITableViewDataSource, tableModelDragDropDelegate: TableModelDragDropDelegate) {
        self.tableViewDataSource = tableViewDataSource
        self.tableModelDragDropDelegate = tableModelDragDropDelegate
    }
}

// MARK: - Table View Drag Delegate
@available(iOS 11.0, *)
extension TableDragDropDelegate: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    // Multi-row drag
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(item: nil, typeIdentifier: nil)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        dragItem.localObject = indexPath
        
        return [dragItem]
    }
}

// MARK: Table View Drop Delegate
@available(iOS 11.0, *)
extension TableDragDropDelegate: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        guard destinationIndexPath != nil else {
            let cancelProposal = UITableViewDropProposal(operation: .cancel, intent: .automatic)
            return cancelProposal
        }
        
        if session.items.count == 1 {
            let singleRowProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            return singleRowProposal
        } else {
            let multiRowProposal = UITableViewDropProposal(operation: .move, intent: .unspecified)
            return multiRowProposal
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        // Prevent a crash from attempting to insert rows beyond the last row of the section
        let rowsInSection = tableViewDataSource.tableView(tableView, numberOfRowsInSection: destinationIndexPath.section)
        let correctedDestination: IndexPath
        if destinationIndexPath.row < rowsInSection {
            correctedDestination = destinationIndexPath
        } else {
            correctedDestination = IndexPath(row: rowsInSection - 1, section: destinationIndexPath.section)
        }
        
        // Get ready
        
        let items = coordinator.items
        
        var sourcePathsInSelectionOrder = [IndexPath]()
        var targetIndexPath = correctedDestination
        
        for item in items {
            // Collect the source index paths in their selection order
            guard let sourcePath = item.dragItem.localObject as? IndexPath else { return }
            sourcePathsInSelectionOrder.append(sourcePath)
            
            // Decrement the target index path by one for every source path preceding the destination path
            if sourcePath < correctedDestination {
                targetIndexPath.row -= 1
            }
        }
        
        // Update model
        
        guard tableModelDragDropDelegate.updateModelOnDrop(sourcePathsInSelectionOrder, targetIndexPath: targetIndexPath) == true else { return }
        
        // Update table view
        
        /*
         Three possibilities:
         
         1. The destination path is before the earliest source path. Update from the destination path through the latest source path
         2. The destination path is between the earliest and latest source paths. Update from the earliest through latest souce paths
         3. The destination path is after the latest source path. Update from the earliest source path through one before the destination path
         
         */
        
        // Set start and end of update
        let sourcePathsInReverseIndexOrder = sourcePathsInSelectionOrder.sorted(by: >)
        
        guard let topSrc = sourcePathsInReverseIndexOrder.last, let bottomSrc = sourcePathsInReverseIndexOrder.first else { return }
        let destination = correctedDestination
        let startUpdatePath = destination < topSrc ? destination : topSrc
        
        let endUpdatePath: IndexPath
        if destination > bottomSrc {
            endUpdatePath = IndexPath(row: destination.row - 1, section: destination.section)
        } else {
            endUpdatePath = bottomSrc
        }
        
        // Create paths to update. Tracking which are above and below the destination is nice for the animation
        var pathsAboveDestination = [IndexPath]()
        var pathsAtDestinationAndBelow = [IndexPath]()
        
        for row in startUpdatePath.row...endUpdatePath.row {
            let path = IndexPath(row: row, section: destination.section)
            if path < correctedDestination {
                pathsAboveDestination.append(path)
            } else {
                pathsAtDestinationAndBelow.append(path)
            }
        }
        
        // Animate the row updates
        tableView.reloadRows(at: pathsAboveDestination, with: .top)
        tableView.reloadRows(at: pathsAtDestinationAndBelow, with: .bottom)
    }
}

