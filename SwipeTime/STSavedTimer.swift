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
    
    init(centiseconds: Int, isFavorite: Bool) {
        self.centiseconds = centiseconds
        self.isFavorite = isFavorite
    }
    
    init(centiseconds: Int) {
        self.centiseconds = centiseconds
        self.isFavorite = false
    }
    
    override init() {
        self.centiseconds = 3000
        self.isFavorite = true
    }
    
    // MARK: - Types
    
    struct PropertyKey {
        static let centisecondsKey = "centiseconds"
        static let isFavoriteKey = "isFavorite"
    }
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(centiseconds, forKey: PropertyKey.centisecondsKey)
        aCoder.encode(isFavorite, forKey: PropertyKey.isFavoriteKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let centiseconds = aDecoder.decodeInteger(forKey: PropertyKey.centisecondsKey)
        let isFavorite = aDecoder.decodeBool(forKey: PropertyKey.isFavoriteKey)
        
        self.init(centiseconds: centiseconds, isFavorite: isFavorite)
    }
}
