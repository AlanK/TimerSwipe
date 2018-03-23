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
    
    // MARK: Initializers
    
    static func instantiate() -> ListController {
        let storyboard = UIStoryboard.init(name: "ListController", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "ListController") as! ListController
        
        return vc
    }
    
    // MARK: Outlets
    
    @IBOutlet var tableView: UITableView!
}
