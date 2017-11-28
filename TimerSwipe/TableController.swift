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
    static private func footerTextwhenVoiceOverIs(_ enabled: Bool) -> String {
        return enabled ? NSLocalizedString("voiceOverFooter", value: "Mark a timer favorite to open it by default.", comment: "") : NSLocalizedString("defaultFooter", value: "Mark a timer ♥︎ to open it by default.", comment: "")
    }
    /// Controller holding the app model
    private lazy var modelIntermediary: ModelIntermediary? = self.navigationController as? ModelIntermediary
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
        view.textField.delegate = self
        return view
    }()
    
    private let cellID = "STTableViewCell"
    private let sectionsInTableView = 1, mainSection = 0
    
    private lazy var accessibleFirstFocus: UIResponder? = {
        guard let model = modelIntermediary?.model else {return nil}
        let count = model.count()
        guard count > 0 else {return nil}
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
        voiceOverStatusDidChange()
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
        
        guard let accessibleFirstFocus = accessibleFirstFocus else {return}
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, accessibleFirstFocus)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Make sure keyboard accessory view isn’t stuck to the bottom of the screen when we unwind to this view
        if keyboardAccessoryView.isVisible {exitKeyboardAccessoryView()}
        
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
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.addButton)
        } else {
            let newIndexPath = (indexPath.row == 0) ? indexPath : IndexPath.init(row: indexPath.row - 1, section: mainSection)
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tableView.cellForRow(at: newIndexPath))
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        guard let model = modelIntermediary?.model else {return}
        let timer = model.remove(at: fromIndexPath.row)
        model.insert(timer, at: toIndexPath.row)
    }
    
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
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tableView.cellForRow(at: newIndexPath))
    }
    
    /// Enable the Edit button when the table has one or more rows
    func refreshEditButton() {
        let isEnabled: Bool
        if let model = modelIntermediary?.model {
            isEnabled = (model.count() > 0)
        } else {
            isEnabled = false
        }
        self.navigationItem.leftBarButtonItem?.isEnabled = isEnabled
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
        accessibleFirstFocus = selectedCell
        // Set the destination view controller's providedDuration to the timer value
        controller.providedDuration = timer.seconds
    }
}

// MARK: - Table Cell Delegate
extension TableController: TableCellDelegate {
    /// Handles taps on the custom accessory view on the table view cells
    func cellButtonTapped(cell: TableCell) {
        let indexPath = tableView.indexPath(for: cell)
        
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
        let charCount = textField.text?.count ?? 0
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        let maxLength = 3
        
        // Prevent crash-on-undo when a text insertion was blocked by this code
        // Prevent non-number characters from being inserted
        // Prevent too many characters from being inserted
        return (range.length + range.location <= charCount &&
            string.rangeOfCharacter(from: invalidCharacters) == nil &&
            charCount + string.count - range.length <= maxLength)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createNewTimer()
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
        let isEnabled: Bool
        if let text = textField.text {
            isEnabled = (text.count > 0)
        } else {
            isEnabled = false
        }
        keyboardAccessoryView.addButton.isEnabled = isEnabled
    }
    
    
    /// Resets and hides the input accessory
    @objc func exitKeyboardAccessoryView() {
        // Clear the text field
        keyboardAccessoryView.textField.text?.removeAll()
        // Ditch the keyboard and hide
        makeKAV(visible: false)
    }
    
    override func accessibilityPerformEscape() -> Bool {
        exitKeyboardAccessoryView()
        return true
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
}

extension TableController: VoiceOverObserver {
    func voiceOverStatusDidChange(_: Notification? = nil) {
        let voiceOverOn = UIAccessibilityIsVoiceOverRunning()
        
        footer.text = TableController.footerTextwhenVoiceOverIs(voiceOverOn)
        tableView.tableFooterView?.layoutIfNeeded()
    }
}

@available(iOS 11.0, *)
extension TableController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
//    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
//        return dragItems(at: indexPath)
//    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(item: nil, typeIdentifier: nil)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

@available(iOS 11.0, *)
extension TableController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
}