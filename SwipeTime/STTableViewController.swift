//
//  STTableViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

protocol ModelController {
    var model: STTimerList? {get}
}

class STTableViewController: UITableViewController {
    var modelController: ModelController?
    
    @IBOutlet var footerContainer: UIView!
    @IBOutlet var footer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelController = self.navigationController as? ModelController
        
        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let footerView = tableView.tableFooterView else {return}
        let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = footerView.frame
        
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

    override func numberOfSections(in tableView: UITableView) -> Int {return K.sectionsInTableView}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelController?.model?.count() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID, for: indexPath)
        if let cell = cell as? STTableViewCell,
            let cellTimer = modelController?.model?[indexPath.row] {
            cell.delegate = self
            cell.setupCell(with: cellTimer)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    func segueToSTViewController(via segue: UIStoryboardSegue, from sender: Any?) {
        guard let controller = segue.destination as? STViewController,
            let selectedCell = sender as? STTableViewCell,
            let indexPath = tableView.indexPath(for: selectedCell),
            let model = modelController?.model else {return}
        let timer = model[indexPath.row]
        controller.providedDuration = timer.centiseconds
    }
    
    @IBAction func unwindToSTTVC(_ sender: UIStoryboardSegue) {
        
        
        // I probably need to rip some of this code out and move it to MainNavController or a struct or something.
        
        
        guard let sourceViewController = sender.source as? STModalViewController,
            let userSelectedTime = sourceViewController.userSelectedTime,
            let model = modelController?.model else {return}
        let newTimer = STSavedTimer(centiseconds: userSelectedTime)
        let newIndexPath = IndexPath(row: model.count(), section: K.mainSection)
        
        model.append(timer: newTimer)
        model.saveData()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}

extension STTableViewController: STTableViewCellDelegate {
    func cellButtonTapped(cell: STTableViewCell) {
        let indexPath = self.tableView.indexPathForRow(at: cell.center)
        
        guard let index = indexPath?.row, let model = modelController?.model else {return}
        model.toggleFavorite(at: index)
        model.saveData()
        tableView.reloadData()
    }
}
