//
//  STTableViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STTableViewController: UITableViewController {
    var savedTimerList = STTimerList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedTimerList.readData()
        
        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Navigate to the correct entry point
        guard let favoriteTimer = savedTimerList.favorite() else {return}
        performSegue(withIdentifier: "tableToTimer", sender: favoriteTimer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {return 1}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTimerList.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "STTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! STTableViewCell
        let cellTimer = savedTimerList[indexPath.row]
        cell.delegate = self
        cell.setupCell(with: cellTimer)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        _ = savedTimerList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let movingTimer = savedTimerList.remove(at: fromIndexPath.row)
        savedTimerList.insert(movingTimer, at: toIndexPath.row)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        savedTimerList.saveData()
        super.setEditing(editing, animated: animated)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "tableToTimer" else {return}
        let timerScreen = segue.destination as! STViewController
        var selectedTimer: STSavedTimer
        
        if let selectedTimerCell = sender as? STTableViewCell {
            let indexPath = tableView.indexPath(for: selectedTimerCell)
            selectedTimer = savedTimerList[indexPath!.row]
        } else {selectedTimer = sender as! STSavedTimer}
        
        timerScreen.providedDuration = selectedTimer.centiseconds
    }
    
    @IBAction func unwindToSTTVC(_ sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.source as? STModalViewController,
            let userSelectedTime = sourceViewController.userSelectedTime else {return}
        let newTimer = STSavedTimer(centiseconds: userSelectedTime)
        let newIndexPath = IndexPath(row: savedTimerList.count(), section: 0)
        
        savedTimerList.append(timer: newTimer)
        tableView.insertRows(at: [newIndexPath], with: .bottom)
        savedTimerList.saveData()
    }
}

extension STTableViewController: STTableViewCellDelegate {
    func cellButtonTapped(cell: STTableViewCell) {
        let indexPath = self.tableView.indexPathForRow(at: cell.center)
        
        guard let index = indexPath?.row else {return}
        savedTimerList.toggleFavorite(at: index)
        savedTimerList.saveData()
        tableView.reloadData()
    }
}
