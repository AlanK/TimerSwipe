//
//  ListController.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/23/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

class ListController: UIViewController {
    // MARK: Dependencies
    
    private var model: Model!
    private var dataSourceAndDelegate: ListDataSourceAndDelegate!
    
    // MARK: Initializers
    
    static func instantiate(model: Model) -> ListController {
        let storyboard = UIStoryboard.init(name: "ListController", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "ListController") as! ListController
        
        vc.model = model
        vc.dataSourceAndDelegate = ListDataSourceAndDelegate(model)
        
        return vc
    }
    
    // MARK: Outlets
    
    @IBOutlet var tableView: UITableView!
}
