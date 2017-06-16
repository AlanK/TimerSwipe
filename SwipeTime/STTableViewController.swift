//
//  STTableViewController.swift
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

class STTableViewController: UITableViewController {
    /// Controller holding the app model
    var modelController: ModelController?
    /// The UIView containing the table footer
    @IBOutlet var footerContainer: UIView!
    /// The label serving as the table footer
    @IBOutlet var footer: UILabel!
    
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
        // If the correct height doesn't match the frame, apply the correct height and reattach the footer
        guard height != frame.size.height else {return}
        frame.size.height = height
        footerView.frame = frame
        tableView.tableFooterView = footerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Table view data source

    // This table has one section
    override func numberOfSections(in tableView: UITableView) -> Int {return K.sectionsInTableView}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelController?.model?.count() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID, for: indexPath)
        // Pass delegate and timer to cell so it can complete its own setup
        if let cell = cell as? STTableViewCell,
            let cellTimer = modelController?.model?[indexPath.row] {
            cell.delegate = self
            cell.setupCell(with: cellTimer)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Don't delete the row if the model can't be updated
        guard editingStyle == .delete,
            let _ = modelController?.model?.remove(at: indexPath.row) else {return}
        tableView.deleteRows(at: [indexPath], with: .automatic)
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueID.tableToTimer.rawValue {
            segueToSTViewController(via: segue, from: sender)
        }
    }
    
    /// Prepare for segue to the primary/timer view
    private func segueToSTViewController(via segue: UIStoryboardSegue, from sender: Any?) {
        guard let controller = segue.destination as? STViewController,
            let selectedCell = sender as? STTableViewCell,
            let indexPath = tableView.indexPath(for: selectedCell),
            let model = modelController?.model else {return}
        let timer = model[indexPath.row]
        // Set the destination view controller's providedDuration to the timer value
        controller.providedDuration = timer.centiseconds
    }
    
    /// Handle the return to the table view from the modal time entry view
    @IBAction func unwindToSTTVC(_ sender: UIStoryboardSegue) {
        // Ensure we're arriving from the right source and extract useful info
        guard let sourceViewController = sender.source as? STModalViewController,
            let userSelectedTime = sourceViewController.userSelectedTime,
            let model = modelController?.model else {return}
        let newTimer = STSavedTimer(centiseconds: userSelectedTime)
        let newIndexPath = IndexPath(row: model.count(), section: K.mainSection)
        // Append, save, and update view
        model.append(timer: newTimer)
        model.saveData()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}

extension STTableViewController: STTableViewCellDelegate {
    /// Handles taps on the custom accessory view on the table view cells
    func cellButtonTapped(cell: STTableViewCell) {
        // Indirectly get the cell index path by finding the index path for the cell located where the cell that was tapped was located…
        let indexPath = self.tableView.indexPathForRow(at: cell.center)
        
        guard let index = indexPath?.row, let model = modelController?.model else {return}
        // Update favorite timer, save, and reload the view
        model.toggleFavorite(at: index)
        model.saveData()
        tableView.reloadData()
    }
}
