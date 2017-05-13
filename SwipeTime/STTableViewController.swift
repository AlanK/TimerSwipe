//
//  STTableViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STTableViewController: UITableViewController, STTableViewCellDelegate {
    var savedTimerList = STTimerList()
    let firstRow = IndexPath.init(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readData()
        
        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Navigate to the correct entry point
        
        // Delete me -->
        var fav: STSavedTimer?
        fav = savedTimerList.favorite()
        // <-- Delete me
        
        guard let favoriteTimer = fav else {return}
        performSegue(withIdentifier: "tableToTimer", sender: favoriteTimer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func setIconToFavorite(cell: STTableViewCell) {
        cell.favoriteIcon.setImage(UIImage(named: "Full heart")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
    }
    
    func setIconToNotFavorite(cell: STTableViewCell) {
        cell.favoriteIcon.setImage(UIImage(named: "Empty heart")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
    }
    
    func reloadRowsInRange(low: Int, high: Int) {
        var indexPaths = [IndexPath]()
        for position in low...high {
            let indexPath = IndexPath.init(row: position, section: 0)
            indexPaths.append(indexPath)
        }
        tableView.reloadRows(at: indexPaths, with: .none)
    }
    
    func cellButtonTapped(cell: STTableViewCell) {
        let indexPath = self.tableView.indexPathForRow(at: cell.center)
        self.savedTimerList.markFavorite(at: indexPath!.row)
        saveData()
        tableView.reloadData()
    }
    
    // MARK: - Persist data
    
    func saveData() {
        let persistentList = NSKeyedArchiver.archivedData(withRootObject: savedTimerList)
        UserDefaults.standard.set(persistentList, forKey: "persistedList")
        print("Saved data!")
    }
    
    func readData() {
        guard let persistentList = UserDefaults.standard.object(forKey: "persistedList") else {
            savedTimerList.loadSampleTimers()
            return
        }
        savedTimerList = NSKeyedUnarchiver.unarchiveObject(with: persistentList as! Data) as! STTimerList
        print("Read data!")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTimerList.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "STTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! STTableViewCell
        
        let savedTimer = savedTimerList[indexPath.row]
        cell.delegate = self
        cell.secondsLabel.text = String(savedTimer.centiseconds/100) + " seconds"
        switch savedTimer.isFavorite {
        case true: setIconToFavorite(cell: cell)
        case false: setIconToNotFavorite(cell: cell)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Awkwardly don't allow the last row to be deleted
            guard savedTimerList.count() != 1 else {return}
            _ = savedTimerList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let movingTimer = savedTimerList.remove(at: fromIndexPath.row)
        savedTimerList.insert(movingTimer, at: toIndexPath.row)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        saveData()
        super.setEditing(editing, animated: animated)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToTimer" {
            let timerScreen = segue.destination as! STViewController
            var selectedTimer: STSavedTimer

            if let selectedTimerCell = sender as? STTableViewCell {
                let indexPath = tableView.indexPath(for: selectedTimerCell)
                selectedTimer = savedTimerList[indexPath!.row]
            }
            else {
                selectedTimer = sender as! STSavedTimer
            }
            timerScreen.providedDuration = selectedTimer.centiseconds
        }
    }
    
    @IBAction func unwindToSTTVC(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? STModalViewController {
            if let userSelectedTime = sourceViewController.userSelectedTime {
                let newTimer = STSavedTimer(centiseconds: userSelectedTime)
                let newIndexPath = IndexPath(row: savedTimerList.count(), section: 0)
                
                savedTimerList.append(timer: newTimer)
                tableView.insertRows(at: [newIndexPath], with: .bottom)
                saveData()
            }
        }
    }
}
