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
            tableView.dragDelegate = self
            tableView.dropDelegate = self
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

// MARK: - Table View Drag Delegate
@available(iOS 11.0, *)
extension TableController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    // Multi-row drag
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(item: nil, typeIdentifier: nil)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        dragItem.localObject = indexPath
        
        return [dragItem]
    }
}

// MARK: Table View Drop Delegate
@available(iOS 11.0, *)
extension TableController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        let singleRowProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath),
        multiRowProposal = UITableViewDropProposal(operation: .move, intent: .unspecified),
        cancelProposal = UITableViewDropProposal(operation: .cancel, intent: .automatic)
        
        guard let destinationIndexPath = destinationIndexPath,
            destinationIndexPath.section == mainSection else {
                return cancelProposal
        }
        
        return session.items.count == 1 ? singleRowProposal : multiRowProposal
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let originalPath = coordinator.destinationIndexPath, let model = model else { return }
        let modelCount = model.count()
        let destinationIndexPath = originalPath.row < modelCount ? originalPath : IndexPath.init(row: modelCount - 1, section: mainSection)
        let items = coordinator.items
        
        var sourcePaths = [IndexPath]()
        var targetIndexPath = destinationIndexPath
        var timers = [IndexPath: STSavedTimer]()
        
        // Update model
        
        for item in items {
            // Collect the source index paths in their selection order
            guard let sourcePath = item.dragItem.localObject as? IndexPath else { return }
            sourcePaths.append(sourcePath)
            
            // Decrement the target index path by one for every source path preceding the destination path
            if sourcePath < destinationIndexPath {
                targetIndexPath.row -= 1
            }
        }
        
        // We need to remove the model items being moved from the model. The math is simpler if we start with the lastmost item to be removed and work backwards.
        let sortedSourcePaths = sourcePaths.sorted(by: >)
        
        // Put each model item being removed in a dictionary, with the key being where it was removed from
        for path in sortedSourcePaths {
            timers[path] = model.remove(at: path.row)
        }
        
        // Back the removed model items into their destination
        while sourcePaths.isEmpty == false {
            let path = sourcePaths.removeLast()
            
            guard let timer = timers[path] else { return }
            model.insert(timer, at: targetIndexPath.row)
        }
        
        model.saveData()
        
        // Update table view
        
        // Collect source and destination index paths
        var sourceAndDestinationPaths = sortedSourcePaths
        sourceAndDestinationPaths.append(destinationIndexPath)
        
        // Sort the paths
        let unitedPaths = sourceAndDestinationPaths.sorted(by: >)
        
        // Create a collection of every index path between the smallest and largest
        guard let smallestPath = unitedPaths.last, let largestPath = unitedPaths.first else { return }
        var pathsToUpdate = [IndexPath]()
        
        for row in smallestPath.row...largestPath.row {
            let newPath = IndexPath.init(row: row, section: mainSection)
            pathsToUpdate.append(newPath)
        }
        
        // Execute the row updates
        var pathsAboveDestination = [IndexPath]()
        var pathsAtDestinationAndBelow = [IndexPath]()
        for path in pathsToUpdate {
            if path < destinationIndexPath {
                pathsAboveDestination.append(path)
            } else {
                pathsAtDestinationAndBelow.append(path)
            }
        }
        
        tableView.reloadRows(at: pathsAboveDestination, with: .top)
        tableView.reloadRows(at: pathsAtDestinationAndBelow, with: .bottom)
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
