//
//  TimerSwipeTests.swift
//  TimerSwipeTests
//
//  Created by Alan Kantz on 10/24/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import XCTest
@testable import TimerSwipe

class TimerSwipeTests: XCTestCase {
    func inputViewInitializesInvisible() -> InputView {
        let frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        let inputView = InputView.init(frame: frame, inputViewStyle: .default)
        XCTAssertFalse(inputView.isVisible)
        return inputView
    }
}
