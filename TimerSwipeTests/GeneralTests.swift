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
    
    func testTextFieldDelegateCharacterRejection() {
        let textField = UITextField()
        let textFieldDelegate = TableTFDelegate.init(completionHandler: {})
        
        textField.delegate = textFieldDelegate
        
        let rangeShouldPass: NSRange = NSRange.init(location: 0, length: 1)
        let stringShouldPass: String = "1"
        
        textField.text = "123"
        
        let charactersShouldChange = textFieldDelegate.textField(textField, shouldChangeCharactersIn: rangeShouldPass, replacementString: stringShouldPass)
        XCTAssertTrue(charactersShouldChange)

        let rangeTooDistant: NSRange = NSRange.init(location: 1, length: 3)
        let invalidString: String = "ab"
        
        textField.text = "2"
        
        let charactersShouldNotChangeRangeTooDistant = textFieldDelegate.textField(textField, shouldChangeCharactersIn: rangeTooDistant, replacementString: stringShouldPass)
        XCTAssertFalse(charactersShouldNotChangeRangeTooDistant)
        
        let charactersShouldNotChangeInvalidCharacters = textFieldDelegate.textField(textField, shouldChangeCharactersIn: rangeShouldPass, replacementString: invalidString)
        XCTAssertFalse(charactersShouldNotChangeInvalidCharacters)
    }
    
    func testTextFieldDelegateShouldReturnAndCall() {
        var dummyVar = false
        
        let textField = UITextField()
        let textFieldDelegate = TableTFDelegate.init(completionHandler: { dummyVar = true })
        
        textField.delegate = textFieldDelegate
        
        let textFieldShouldNotReturn = textFieldDelegate.textFieldShouldReturn(textField)
        XCTAssertFalse(textFieldShouldNotReturn)
        XCTAssertTrue(dummyVar)
    }
}
