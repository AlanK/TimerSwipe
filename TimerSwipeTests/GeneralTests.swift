//
//  GeneralTests.swift
//  TimerSwipeTests
//
//  Created by Alan Kantz on 11/26/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import XCTest
@testable import TimerSwipe

class GeneralTests: XCTestCase {
    
    func testTimeFormat() {
        let timeFormatter = TimeFormatter()
        let testString = timeFormatter.display(time: 83.45)
        XCTAssertEqual(testString, "01:23.45")
    }
    
    func testInputViewInitialInvisibility() {
        let frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        let inputView = InputView.init(frame: frame, inputViewStyle: .default)
        XCTAssertFalse(inputView.isVisible)
    }
}
