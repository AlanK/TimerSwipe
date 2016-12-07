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
    let firstRow = IndexPath.init(row: 0, section: 0)
    
    func loadSampleTimers () {
        let timer2 = STSavedTimer(centiseconds: 2000)
        let timer3 = STSavedTimer(centiseconds: 1000)
        savedTimerList.append(timerArray: [timer2, timer3])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        readData()
        
        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Navigate to the correct entry point
        
        performSegue(withIdentifier: "tableToTimer", sender: self)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setIconToFavorite(cell: STTableViewCell) {
        cell.favoriteIcon.setTitle("◉", for: UIControlState())
    }
    
    func setIconToNotFavorite(cell: STTableViewCell) {
        cell.favoriteIcon.setTitle("◎", for: UIControlState())
    }
    
    func reloadRowsInRange(low: Int, high: Int) {
        var indexPaths = [IndexPath]()
        for position in low...high {
            let indexPath = IndexPath.init(row: position, section: 0)
            indexPaths.append(indexPath)
        }
        tableView.reloadRows(at: indexPaths, with: .none)
    }

    
    // MARK: - Persist data
    
    func saveData() {
        let persistentList = NSKeyedArchiver.archivedData(withRootObject: savedTimerList)
        UserDefaults.standard.set(persistentList, forKey: "persistedList")
        print("Saved data!")
    }
    
    func readData() {
        if let persistentList = UserDefaults.standard.object(forKey: "persistedList") {
            savedTimerList = NSKeyedUnarchiver.unarchiveObject(with: persistentList as! Data) as! STTimerList
            print("Read data!")
        }
        
        else {
            loadSampleTimers()
        }
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
        
        cell.containingTable = self
        cell.tapAction = { (cell) in
            self.savedTimerList.markFavorite(at: indexPath.row)
            self.saveData()
            self.tableView.reloadData()
        }
        
        cell.secondsLabel.text = String(savedTimer.centiseconds/100) + " seconds"
        if savedTimer.isFavorite {
            setIconToFavorite(cell: cell)
        } else {
            setIconToNotFavorite(cell: cell)
        }

        return cell
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            // Awkwardly don't allow the last row to be deleted
            guard savedTimerList.count() != 1 else {
                return
            }
            
            // Check if I'm removing the favorite
            if savedTimerList[indexPath.row].isFavorite == true {
                // Make the first row the new favorite (unless I'm deleting the first row, in which case the second row should be the new favorite)
                var newFavorite = indexPath == firstRow ? IndexPath.init(row: 1, section: 0) : firstRow
                savedTimerList.markFavorite(at: newFavorite.row)
                tableView.reloadRows(at: [newFavorite], with: .none)
            }
            savedTimerList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let movingTimer = savedTimerList.remove(at: fromIndexPath.row)
        savedTimerList.insert(movingTimer, at: toIndexPath.row)
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
                selectedTimer = savedTimerList.favorite()
            }
            
            timerScreen.providedDuration = selectedTimer.centiseconds
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
