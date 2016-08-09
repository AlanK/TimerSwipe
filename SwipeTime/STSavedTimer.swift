//
//  STSavedTimer.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/8/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

struct STSavedTimer {
    let milliseconds: Int
    var favorite: Bool
    
    init(milliseconds: Int) {
        self.milliseconds = milliseconds
        self.favorite = false
    }
}