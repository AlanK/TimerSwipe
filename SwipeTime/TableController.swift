//
//  TableController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// The controller that holds the app model
protocol ModelController {
    /// The app model
    var model: STTimerList? {get}
}

/// The main table in the app
class TableController: UITableViewController {
    /// Controller holding the app model
    private var modelController: ModelController?
    /// The UIView containing the table footer
    @IBOutlet var footerContainer: UIView!
    /// The label serving as the table footer
    @IBOutlet var footer: UILabel!
    
    // MARK: View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// The root navigation controller serving as the home of the app model
        modelController = self.navigationController as? ModelController
        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Apply layout to the footer
        // Get the auto layout-determined height of the footer and its actual frame
        guard let footerView = tableView.tableFooterView else {return}
        let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = footerView.frame
        // If the correct height doesn't match the frame, apply the correct height and re-attach the footer
        guard height != frame.size.height else {return}
        frame.size.height = height
        footerView.frame = frame
        tableView.tableFooterView = footerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        guard let model = modelController?.model else {return}
        self.navigationItem.rightBarButtonItem?.isEnabled = (model.count() > 0)
}

    // MARK: Table view data source

    // This table has one section
    override func numberOfSections(in tableView: UITableView) -> Int {return K.sectionsInTableView}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return modelController?.model?.count() ?? 0}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID, for: indexPath)
        // Pass delegate and timer to cell so it can complete its own setup
        if let cell = cell as? TableCell,
            let cellTimer = modelController?.model?[indexPath.row] {
            cell.delegate = self
            cell.setupCell(with: cellTimer)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Don't delete the row if the model can't be updated
        guard editingStyle == .delete, let model = modelController?.model else {return}
        let _ = model.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        self.navigationItem.rightBarButtonItem?.isEnabled = (model.count() > 0)
        if model.count() == 0 {
            let nearFuture = DispatchTime.now() + K.editButtonDelay
            let work = DispatchWorkItem {
                self.setEditing(false, animated: false)
            }
            DispatchQueue.main.asyncAfter(deadline: nearFuture, execute: work)
        }
}

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        guard let model = modelController?.model else {return}
        let timer = model.remove(at: fromIndexPath.row)
        model.insert(timer, at: toIndexPath.row)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        modelController?.model?.saveData()
        super.setEditing(editing, animated: animated)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // More segues might exist in the future, so let's keep this short and factor out the realy work
        if segue.identifier == SegueID.tableToTimer.rawValue {
            segueToMainViewController(for: segue, sender: sender)
        }
    }
    
    /**
     Prepare for segue to the main view controller specifically. This has the same signature as `prepare(for:sender:)` for convenience.
     - parameters:
         - segue: The `TableToTimer` storyboard segue
         - sender: A `TableCell`
     */
    private func segueToMainViewController(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? MainViewController,
            let selectedCell = sender as? TableCell,
            let indexPath = tableView.indexPath(for: selectedCell),
            let model = modelController?.model else {return}
        let timer = model[indexPath.row]
        // Set the destination view controller's providedDuration to the timer value
        controller.providedDuration = timer.centiseconds
    }
    
    /// Handle the return to the table view from the main view controller
    @IBAction func unwindToSTTVC(_ sender: UIStoryboardSegue) {
        // Ensure we're arriving from the right source and extract useful info
        guard let sourceViewController = sender.source as? InputController,
            let userSelectedTime = sourceViewController.userSelectedTime,
            let model = modelController?.model else {return}
        let newTimer = STSavedTimer(centiseconds: userSelectedTime)
        let newIndexPath = IndexPath(row: model.count(), section: K.mainSection)
        // Append, save, and update view
        model.append(timer: newTimer)
        model.saveData()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        self.navigationItem.rightBarButtonItem?.isEnabled = (model.count() > 0)
    }
}

// MARK: - Table Cell Delegate
extension TableController: TableCellDelegate {
    /// Handles taps on the custom accessory view on the table view cells
    func cellButtonTapped(cell: TableCell) {
        // Indirectly get the cell index path by finding the index path for the cell located where the cell that was tapped was located…
        let indexPath = self.tableView.indexPathForRow(at: cell.center)
        
        guard let index = indexPath?.row, let model = modelController?.model else {return}
        // Update favorite timer, save, and reload the view
        model.toggleFavorite(at: index)
        model.saveData()
        tableView.reloadData()
    }
}
