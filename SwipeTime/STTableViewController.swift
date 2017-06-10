//
//  STTableViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STTableViewController: UITableViewController {
    var timerList = STTimerList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerList.readData()
        
        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Navigate to the correct entry point
        guard let favoriteTimer = timerList.favorite() else {return}
        performSegue(withIdentifier: SegueID.tableToTimer.rawValue, sender: favoriteTimer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {return constants.sectionsInTableView}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timerList.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: constants.cellID, for: indexPath) as! STTableViewCell
        let cellTimer = timerList[indexPath.row]

        cell.delegate = self
        cell.setupCell(with: cellTimer)

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        _ = timerList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let timer = timerList.remove(at: fromIndexPath.row)
        timerList.insert(timer, at: toIndexPath.row)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        timerList.saveData()
        super.setEditing(editing, animated: animated)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueID.tableToTimer.rawValue {
            segueToSTViewController(via: segue, from: sender)
        }
    }
    
    func segueToSTViewController(via segue: UIStoryboardSegue, from sender: Any?) {
        guard let controller = segue.destination as? STViewController else {return}
        var timer: STSavedTimer
        if let selectedCell = sender as? STTableViewCell {
            let indexPath = tableView.indexPath(for: selectedCell)
            timer = timerList[indexPath!.row]
        } else {timer = sender as! STSavedTimer}
        controller.providedDuration = timer.centiseconds
    }
    
    @IBAction func unwindToSTTVC(_ sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? STModalViewController,
            let userSelectedTime = sourceViewController.userSelectedTime else {return}
        let newTimer = STSavedTimer(centiseconds: userSelectedTime)
        let newIndexPath = IndexPath(row: timerList.count(), section: 0)
        
        timerList.append(timer: newTimer)
        tableView.insertRows(at: [newIndexPath], with: .bottom)
        timerList.saveData()
    }
}

extension STTableViewController: STTableViewCellDelegate {
    func cellButtonTapped(cell: STTableViewCell) {
        let indexPath = self.tableView.indexPathForRow(at: cell.center)
        
        guard let index = indexPath?.row else {return}
        timerList.toggleFavorite(at: index)
        timerList.saveData()
        tableView.reloadData()
    }
}
