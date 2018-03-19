//
//  CustomAccessibilityAction.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 3/19/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

class CustomAccessibilityAction: UIAccessibilityCustomAction {
    // MARK: Dependencies
    
    private let namer: (() -> String)?
    
    // MARK: Initializers
    
    init(target: Any?, selector: Selector, namer: @escaping () -> String) {
        self.namer = namer
        super.init(name: namer(), target: target, selector: selector)
    }
    
    // MARK: Overrides
    
    override var name: String {
        get { return namer?() ?? super.name }
        set { super.name = newValue }
    }
}
