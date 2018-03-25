//
//  ListController.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/23/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

protocol ListControllerDelegate: AnyObject {
    func didSelect(_: STSavedTimer, vc: ListController)
    func addButtonActivated(vc: ListController)
}

class ListController: UIViewController {
    // MARK: Dependencies
    
    private weak var delegate: ListControllerDelegate!
    private var dataSourceAndDelegate: ListDataSourceAndDelegate!
    
    // MARK: Initializers
    
    static func instantiate(delegate: ListControllerDelegate, model: Model) -> ListController {
        let storyboard = UIStoryboard.init(name: "ListController", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "ListController") as! ListController
        
        vc.delegate = delegate
        vc.dataSourceAndDelegate = ListDataSourceAndDelegate(vc, model: model)
        
        return vc
    }
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = self.editButtonItem
        editButtonItem.action = #selector(editButtonActivated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let indexPath = tableView.indexPathForSelectedRow { tableView.deselectRow(at: indexPath, animated: true) }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        dataSourceAndDelegate.saveState()
        super.setEditing(editing, animated: animated)
    }
    
    // MARK: Actions
    
    
    @IBAction func addButtonActivated(_ sender: Any) { delegate.addButtonActivated(vc: self) }
    
    // MARK: Outlets
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = dataSourceAndDelegate
            tableView.delegate = dataSourceAndDelegate
            tableView.reloadData()
        }
    }
    
    @IBOutlet var addButton: UIBarButtonItem!
    
    // MARK: Methods
    
    @objc func editButtonActivated() {
        setEditing(!isEditing, animated: true)
        tableView.setEditing(isEditing, animated: true)
    }
    
    /// Enable the Edit button when the table has one or more rows
    func refreshEditButton() { editButtonItem.isEnabled = dataSourceAndDelegate.canEdit }
    
    func didSelect(_ timer: STSavedTimer) { delegate.didSelect(timer, vc: self) }
}
