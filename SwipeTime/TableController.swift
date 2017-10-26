//
//  TableController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// The controller that holds the app model
protocol ModelIntermediary {
    /// The app model
    var model: STTimerList {get}
}

/// The main table in the app
class TableController: UITableViewController {
    /// Controller holding the app model
    private var modelIntermediary: ModelIntermediary?
    /// The UIView containing the table footer
    @IBOutlet var footerContainer: UIView!
    /// The label serving as the table footer
    @IBOutlet var footer: UILabel!
    /// The view which can create new timers
    let keyboardAccessoryView: InputView = {
        let view = InputView(frame: .zero, inputViewStyle: .default)
        view.cancelButton.addTarget(self, action: #selector(exitKeyboardAccessoryView), for: .touchUpInside)
        view.addButton.addTarget(self, action: #selector(commitNewTimer), for: .touchUpInside)
        return view
    }()
    
    private let cellID = "STTableViewCell"
    private let sectionsInTableView = 1, mainSection = 0

    @IBAction func inputNewTimer(_ sender: Any) {
        keyboardAccessoryView.addButton.isEnabled = false
        keyboardAccessoryView.isVisible = true
        keyboardAccessoryView.textField.becomeFirstResponder()
    }
    
    // MARK: View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelIntermediary = self.navigationController as? ModelIntermediary
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Ready input accessory
        keyboardAccessoryView.textField.delegate = self
        keyboardAccessoryView.textField.addTarget(self, action: #selector(textInTextFieldChanged(_:)), for: UIControlEvents.editingChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Apply layout to the footer
        guard let footerView = tableView.tableFooterView else {return}
        // Get the auto layout-determined height of the footer and its actual frame
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
        // This view should have a navigation bar and toolbar
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
        
        refreshEditButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Make sure keyboard accessory view isn’t stuck to the bottom of the screen when we unwind to this view
        exitKeyboardAccessoryView()
        
        super.viewWillDisappear(animated)
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {return sectionsInTableView}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return modelIntermediary?.model.count() ?? 0}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        // Pass delegate and timer to cell so it can complete its own setup
        if let cell = cell as? TableCell, let cellTimer = modelIntermediary?.model[indexPath.row] {
            cell.delegate = self
            cell.setupCell(with: cellTimer)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Don't delete the row if the model can't be updated
        guard editingStyle == .delete, let model = modelIntermediary?.model else {return}
        let _ = model.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        refreshEditButton()
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
        guard let model = modelIntermediary?.model else {return}
        let timer = model.remove(at: fromIndexPath.row)
        model.insert(timer, at: toIndexPath.row)
    }
    
    // MARK: Custom logic
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        modelIntermediary?.model.saveData()
        super.setEditing(editing, animated: animated)
    }
    
    func commitTimer(_ userSelectedTime: TimeInterval) {
        // Create a new timer
        guard let model = modelIntermediary?.model else {return}
        let newTimer = STSavedTimer(seconds: userSelectedTime)
        let newIndexPath = IndexPath(row: model.count(), section: mainSection)
        // Append, save, and update view
        model.append(timer: newTimer)
        model.saveData()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        refreshEditButton()
    }
    
    /// Enable the Edit button when the table has one or more rows
    func refreshEditButton() {
        let isEnabled: Bool
        if let model = modelIntermediary?.model {
            isEnabled = (model.count() > 0)
        } else {
            isEnabled = false
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
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
            let model = modelIntermediary?.model else {return}
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
        
        guard let index = indexPath?.row, let model = modelIntermediary?.model else {return}
        // Update favorite timer, save, and reload the view
        model.toggleFavorite(at: index)
        model.saveData()
        tableView.reloadData()
    }
}

// MARK: - Text Field Delegate
extension TableController: UITextFieldDelegate {
    // Protect against text-related problems
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let charCount = textField.text?.characters.count ?? 0
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        let maxLength = 3
        
        // Prevent crash-on-undo when a text insertion was blocked by this code
        // Prevent non-number characters from being inserted
        // Prevent too many characters from being inserted
        return (range.length + range.location <= charCount &&
            string.rangeOfCharacter(from: invalidCharacters) == nil &&
            charCount + string.characters.count - range.length <= maxLength)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitNewTimer()
        return false
    }
}

// MARK: - Input Accessory Controller
extension TableController {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return keyboardAccessoryView
    }
    
    /// Enable and disable the add button based on whether there is text in the text field
    @objc func textInTextFieldChanged(_ textField: UITextField) {
        let isEnabled: Bool
        if let text = textField.text {
            isEnabled = (text.characters.count > 0)
        } else {
            isEnabled = false
        }
        keyboardAccessoryView.addButton.isEnabled = isEnabled
    }

    
    /// Resets and hides the input accessory
    @objc func exitKeyboardAccessoryView() {
        guard keyboardAccessoryView.isVisible else {return}
        // Clear the text field
        keyboardAccessoryView.textField.text?.removeAll()
        // Ditch the keyboard and hide
        keyboardAccessoryView.textField.resignFirstResponder()
        keyboardAccessoryView.isVisible = false
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
        
        commitTimer(userSelectedTime)
    }
}
