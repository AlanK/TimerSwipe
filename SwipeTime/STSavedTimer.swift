//
//  STSavedTimer.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/8/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

class STSavedTimer {
    let milliseconds: Int
    var isFavorite: Bool
    
    init(milliseconds: Int) {
        self.milliseconds = milliseconds
        self.isFavorite = false
    }
    
    init() {
        self.milliseconds = 3000
        self.isFavorite = false
    }
}