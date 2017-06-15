//
//  Constants.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/9/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

enum SegueID: String {
    case tableToTimer = "tableToTimer"
    case tableToNew = "tableToModal"
}

enum StoryboardID: String {
    case mainView = "mainView"
    case tableView = "tableView"
    case modalView = "modalView"
}

struct constants {
    static let cellID = "STTableViewCell"
    static let sectionsInTableView = 1
    static let mainSection = 0
    static let tintColor = UIColor(red: 0.8, green: 0.3, blue: 0.8, alpha: 1.0)
    static let defaultDurationInCentiseconds = 3000
    static let centisecondsPerSecond = 100.0
    static let hundredthOfASecond = 0.01
    static let timersKey = "timers"
    static let persistedList = "persistedList"
}
