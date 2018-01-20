//
//  TableDragDropTests.swift
//  TimerSwipeTests
//
//  Created by Alan Kantz on 12/17/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import XCTest
@testable import TimerSwipe

@available(iOS 11.0, *)
class TableDragDropTests: XCTestCase {
    
    let tableController = UIStoryboard.init(name: Storyboards.main.rawValue, bundle: nil).instantiateViewController(withIdentifier: MainID.tableView.rawValue) as? TableController
    let tableModelDDD: TableModelDragDropDelegate = {
        class TableModelDDD: NSObject, TableModelDragDropDelegate {
            func updateModelOnDrop(_ sourcePaths: [IndexPath], targetIndexPath: IndexPath) -> Bool {
                return true
            }
        }
        
        return TableModelDDD.init()
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTDDDInitialization() {
        guard let tableController = tableController else {
            XCTFail()
            return
        }
        let _ = TableDragDropDelegate.init(tableController, tableModelDragDropDelegate: tableModelDDD)
        
    }
    
}
