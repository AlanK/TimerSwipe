//
//  TableController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/9/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

/// The main table in the app
class TableController: UITableViewController {
    /// App model must be injected by parent
    var model: STTimerList?
    
    private lazy var dragDropDelegate = TableDragDropDelegate.init(self, tableModelDragDropDelegate: self)
    
    /// The table-add button
    @IBOutlet var addButton: UIBarButtonItem! {
        didSet {
            addButton.accessibilityHint = NSLocalizedString("addToTableButton", value: "Creates a new timer", comment: "Allows the user to create a new timer of their preferred duration")
        }
    }
    /// The UIView containing the table footer
    @IBOutlet var footerContainer: UIView!
    /// The label serving as the table footer
    @IBOutlet var footer: UILabel!
    /// The view which can create new timers
    private lazy var keyboardAccessoryView: InputView = {
        let view = InputView(frame: .zero, inputViewStyle: .default)
        view.cancelButton.addTarget(self, action: #selector(exitKeyboardAccessoryView), for: .touchUpInside)
        view.addButton.addTarget(self, action: #selector(createNewTimer), for: .touchUpInside)
        view.textField.addTarget(self, action: #selector(textInTextFieldChanged(_:)), for: UIControlEvents.editingChanged)
        view.textField.delegate = TextFieldDelegate.init(.tableController(createNewTimer))
        return view
    }()
    
    private let cellID = "STTableViewCell"
    private let sectionsInTableView = 1, mainSection = 0
    
    lazy var accessibleFirstFocus: UIResponder? = {
        guard let model = model, model.count() > 0 else { return nil }
        let index = model.favoriteIndex() ?? 0
        return self.tableView.cellForRow(at: IndexPath.init(row: index, section: mainSection))
    }()
    
    @IBAction func inputNewTimer(_ sender: Any) {
        keyboardAccessoryView.addButton.isEnabled = false
        makeKAV(visible: true)
    }
    
    // MARK: View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = dragDropDelegate
            tableView.dropDelegate = dragDropDelegate
            tableView.dragInteractionEnabled = true
        }
        handleVoiceOverStatus()
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
        refreshEditButton()
        handleVoiceOverStatus()
        
        guard let accessibleFirstFocus = accessibleFirstFocus else {return}
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, accessibleFirstFocus)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Make sure keyboard accessory view isn’t stuck to the bottom of the screen when we unwind to this view
        if keyboardAccessoryView.isVisible {exitKeyboardAccessoryView()}
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return sectionsInTableView }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return model?.count() ?? 0 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        // Pass delegate and timer to cell so it can complete its own setup
        if let cell = cell as? TableCell, let cellTimer = model?[indexPath.row] {
            cell.setupCell(delegate: self, timer: cellTimer)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Don't delete the row if the model can't be updated
        guard editingStyle == .delete, let model = model else { return }
        let _ = model.remove(at: indexPath.row)
        model.saveData()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        refreshEditButton()
        // You shouldn't toggle setEditing within this method, so GCD to the rescue
        if model.count() == 0 {
            let nearFuture = DispatchTime.now() + K.editButtonDelay
            let work = DispatchWorkItem {
                self.setEditing(false, animated: false)
            }
            DispatchQueue.main.asyncAfter(deadline: nearFuture, execute: work)
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.addButton)
        } else {
            let newIndexPath = (indexPath.row == 0) ? indexPath : IndexPath.init(row: indexPath.row - 1, section: mainSection)
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tableView.cellForRow(at: newIndexPath))
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        guard let model = model else { return }
        let timer = model.remove(at: fromIndexPath.row)
        model.insert(timer, at: toIndexPath.row)
        model.saveData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        model?.saveData()
        super.setEditing(editing, animated: animated)
    }
    
    func commitTimer(_ userSelectedTime: TimeInterval) {
        // Create a new timer
        guard let model = model else { return }
        let newTimer = STSavedTimer(seconds: userSelectedTime)
        let newIndexPath = IndexPath(row: model.count(), section: mainSection)
        // Append, save, and update view
        model.append(timer: newTimer)
        model.saveData()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        refreshEditButton()
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tableView.cellForRow(at: newIndexPath))
    }
    
    /// Enable the Edit button when the table has one or more rows
    func refreshEditButton() {
        let numberOfTimers = model?.count() ?? 0
        self.navigationItem.leftBarButtonItem?.isEnabled = numberOfTimers > 0
    }
    
    // MARK: - Input Accessory View
    /// Animate keyboard and input accessory view visible or invisible
    func makeKAV(visible: Bool) {
        addButton.isEnabled = !visible
        _ = visible ? keyboardAccessoryView.textField.becomeFirstResponder() : keyboardAccessoryView.textField.resignFirstResponder()
        
        let duration = K.keyboardAnimationDuration
        let options = visible ? K.keyboardAnimateInCurve : K.keyboardAnimateOutCurve
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.keyboardAccessoryView.isVisible = visible
            // MARK: Dangerous superview spelunking
            self.keyboardAccessoryView.supremeView.layoutIfNeeded()
        })
    }
    
    /// Enable and disable the add button based on whether there is text in the text field
    @objc func textInTextFieldChanged(_ textField: UITextField) {
        let charactersInField = textField.text?.count ?? 0
        keyboardAccessoryView.addButton.isEnabled = charactersInField > 0
    }
    
    
    /// Resets and hides the input accessory
    @objc func exitKeyboardAccessoryView() {
        // Clear the text field
        keyboardAccessoryView.textField.text?.removeAll()
        // Ditch the keyboard and hide
        makeKAV(visible: false)
    }
    
    @objc func createNewTimer() {
        defer {
            exitKeyboardAccessoryView()
        }
        // Create a valid userSelectedTime or exit early
        guard let text = keyboardAccessoryView.textField.text, let userTimeInSeconds = Int(text), userTimeInSeconds > 0 else {return}
        let userSelectedTime = TimeInterval(userTimeInSeconds)
        
        commitTimer(userSelectedTime)
    }
    
    // MARK: Accessibility
    
    private func handleVoiceOverStatus() {
        let voiceOverOn = UIAccessibilityIsVoiceOverRunning()
        
        footer.text = TableStrings.footerText(voiceOverOn: voiceOverOn)
        tableView.tableFooterView?.layoutIfNeeded()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // More segues might exist in the future, so let's keep this short and factor out the realy work
        if segue.identifier == SegueID.tableToTimer.rawValue {
            SegueMediator.fromTableControllerToMainViewController(segue: segue, sender: sender)
        }
    }
}

// MARK: - Table Model Drag Drop Delegate
extension TableController: TableModelDragDropDelegate {
    func updateModelOnDrop(_ sourcePaths: [IndexPath], targetIndexPath: IndexPath) -> Bool {
        guard let model = model else { return false }
        let sourcePathsInReverseIndexOrder = sourcePaths.sorted(by: >)
        var sourcePathsInSelectionOrder = sourcePaths
        
        // Put each model item being removed in a dictionary, with the key being where it was removed from
        var timers = [IndexPath: STSavedTimer]()
        for path in sourcePathsInReverseIndexOrder {
            timers[path] = model.remove(at: path.row)
        }
        
        // Back the removed model items into their destination
        while sourcePathsInSelectionOrder.isEmpty == false {
            let path = sourcePathsInSelectionOrder.removeLast()
            
            guard let timer = timers[path] else { return false }
            model.insert(timer, at: targetIndexPath.row)
        }
        
        model.saveData()
        
        return true
    }
}

// MARK: - Table Cell Delegate
extension TableController: TableCellDelegate {
    /// Handles taps on the custom accessory view on the table view cells
    func cellButtonTapped(cell: TableCell) {
        let indexPath = tableView.indexPath(for: cell)
        
        guard let index = indexPath?.row, let model = model else { return }
        // Update favorite timer and save
        let rowsToUpdate = model.updateFavorite(at: index)
        model.saveData()
        
        // Update the table view
        var indexPaths = [IndexPath]()
        for row in rowsToUpdate {
            let path = IndexPath.init(row: row, section: mainSection)
            indexPaths.append(path)
        }
        tableView.reloadRows(at: indexPaths, with: .none)
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
    
    override func accessibilityPerformEscape() -> Bool {
        exitKeyboardAccessoryView()
        return true
    }
}

// MARK: - VoiceOver Observer
extension TableController: VoiceOverObserver {
    func voiceOverStatusDidChange(_: Notification? = nil) {
        handleVoiceOverStatus()
    }
}
