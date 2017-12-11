//
//  TableStrings.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 12/4/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

struct TableStrings {
    static let voiceOverFooter = NSLocalizedString("voiceOverFooter", value: "Mark a timer favorite to open it by default.", comment: ""), defaultFooter = NSLocalizedString("defaultFooter", value: "Mark a timer ♥︎ to open it by default.", comment: "")
    
    static let isFavorite = NSLocalizedString("fav", value: "Favorite", comment: "this is my favorite timer"),
    makeFavorite = NSLocalizedString("makeFav", value: "Make favorite", comment: "make this timer my favorite timer"),
    makeNotFavorite = NSLocalizedString("unfav", value: "Make not favorite", comment: "make this not be my favorite timer")
    
    static func footerText(voiceOverOn: Bool) -> String {
        return voiceOverOn ? voiceOverFooter : defaultFooter
    }
    
    static func numberOfSeconds(_ seconds: Int) -> String {
        let format = NSLocalizedString("number_of_seconds", comment: "")
        return String.localizedStringWithFormat(format, seconds)
    }
}
