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
    var model: STTimerList {get}
}

/// The main table in the app
class TableController: UITableViewController {
    /// Controller holding the app model
    private var modelController: ModelController?
    /// The UIView containing the table footer
    @IBOutlet var footerContainer: UIView!
    /// The label serving as the table footer
    @IBOutlet var footer: UILabel!
    /// The view which can create new timers
    let keyboardAccessoryView: InputView = {
        let view = InputView(frame: .zero, inputViewStyle: .default)
        view.addButton.addTarget(self, action: #selector(commitNewTimer), for: .touchUpInside)
        return view
    }()
    
    // MARK: View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// The root navigation controller serving as the home of the app model
        modelController = self.navigationController as? ModelController
        // Display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        // Ready input accessory
        keyboardAccessoryView.textField.delegate = self
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
    
    override func viewWillDisappear(_ animated: Bool) {
        if keyboardAccessoryView.isVisible {
            // This ensures we don't return to this view and find an input accessory at the bottom of the screen and a cancel button where there should be an add button
            exitKeyboardAccessoryView()
        }
        super.viewWillDisappear(animated)
    }

    // MARK: Table view data source

    // This table has one section
    override func numberOfSections(in tableView: UITableView) -> Int {return K.sectionsInTableView}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return modelController?.model.count() ?? 0}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID, for: indexPath)
        // Pass delegate and timer to cell so it can complete its own setup
        if let cell = cell as? TableCell,
            let cellTimer = modelController?.model[indexPath.row] {
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
        // You shouldn't toggle setEditing within this method, so GCD to the rescue
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
        modelController?.model.saveData()
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
        controller.duration = timer.seconds
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

// MARK: - Text Field Delegate
extension TableController: UITextFieldDelegate {
    // Protect against text-related crashes
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Prevent crash-on-undo when iOS tries to undo a change that was blocked by shouldChangeCharactersInRange = false
        let currentCharacterCount = textField.text?.characters.count ?? 0
        // Prevent more than three characters from being put in the text field
        guard (range.length + range.location <= currentCharacterCount) else {return false}
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 3
    }
}

// MARK: - Input Accessory Controller
extension TableController {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @IBAction func addTimer(_ sender: Any) {
        keyboardAccessoryView.isVisible = true
        keyboardAccessoryView.textField.becomeFirstResponder()
        toggleAddButton(to: .cancel)
    }
    
    override var inputAccessoryView: UIInputView? {
        return keyboardAccessoryView
    }
    
    /// Resets and hides the input accessory
    @objc func exitKeyboardAccessoryView() {
        // Clear the text field
        keyboardAccessoryView.textField.text?.removeAll()
        // Ditch the keyboard, reset the add button, and hide
        keyboardAccessoryView.textField.resignFirstResponder()
        toggleAddButton(to: .add)
        keyboardAccessoryView.isVisible = false
    }
    
    func toggleAddButton(to buttonState: addButtonState) {
        switch buttonState {
        case .add: self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTimer(_:)))
        case .cancel: self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(exitKeyboardAccessoryView))
        }
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = buttonState.text
    }
    
    override func accessibilityPerformEscape() -> Bool {
        exitKeyboardAccessoryView()
        return true
    }
    
    @objc func commitNewTimer() {
        defer {
            exitKeyboardAccessoryView()
        }
        // Create a valid userSelectedTime or exit early
        guard let text = keyboardAccessoryView.textField.text, let userTimeInSeconds = Int(text), userTimeInSeconds > 0 else {return}
        let userSelectedTime = TimeInterval(userTimeInSeconds)
        
        // Create a new timer
        guard let model = modelController?.model else {return}
        let newTimer = STSavedTimer(seconds: userSelectedTime)
        let newIndexPath = IndexPath(row: model.count(), section: K.mainSection)
        // Append, save, and update view
        model.append(timer: newTimer)
        model.saveData()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        self.navigationItem.rightBarButtonItem?.isEnabled = (model.count() > 0)
    }
}
