//
//  STSavedTimer.swift
//  SwipeTime
//
//  Created by Alan Kantz on 8/8/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import Foundation

class STSavedTimer: NSObject, NSCoding {
    let centiseconds: Int
    var isFavorite: Bool
    
    // MARK: - Initializers
    
    // Memberwise initializer enables NSCoding required convenience initializer to work more simply.
    
    required init(centiseconds: Int, isFavorite: Bool) {
        self.centiseconds = centiseconds
        self.isFavorite = isFavorite
    }
    
    init(centiseconds: Int) {
        self.centiseconds = centiseconds
        self.isFavorite = false
    }
    
    override init() {
        self.centiseconds = K.defaultDurationInCentiseconds
        self.isFavorite = true
    }
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(centiseconds, forKey: K.centisecondsKey)
        aCoder.encode(isFavorite, forKey: K.isFavoriteKey)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let centiseconds = aDecoder.decodeInteger(forKey: K.centisecondsKey)
        let isFavorite = aDecoder.decodeBool(forKey: K.isFavoriteKey)
        
        self.init(centiseconds: centiseconds, isFavorite: isFavorite)
    }
}
