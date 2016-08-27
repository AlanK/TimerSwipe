//
//  STSavedTimer.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/8/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

class STSavedTimer {
    let centiseconds: Int
    var isFavorite: Bool
    
    init(centiseconds: Int) {
        self.centiseconds = centiseconds
        self.isFavorite = false
    }
    
    init() {
        self.centiseconds = 3000
        self.isFavorite = false
    }
}