//
//  ListDataSourceAndDelegate.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/23/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

class ListDataSourceAndDelegate: NSObject {
    // MARK: Dependencies
    
    private let model: Model
    
    // MARK: Initializers
    
    init(_ model: Model) {
        self.model = model
        super.init()
    }
}
