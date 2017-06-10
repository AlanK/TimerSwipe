//
//  STViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STViewController: UIViewController {
    
    let timeFormatter = TimeFormatter()
    let soundController = SoundController()
    
    var stopwatch: Stopwatch?
    var buttonStatus = ChangeButtonValues.Change
    
    /// The duration in centiseconds provided by the segue from STTableViewController.
    var providedDuration: Int?
    
    // MARK: - Labels & Buttons
    
    @IBOutlet var timeDisplay: UILabel!
    @IBOutlet var changeButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func changeButton(_ sender: AnyObject) {
        switch buttonStatus {
        case .Change: self.navigationController?.popViewController(animated: true)
        case .Cancel: stopwatch?.clearTimer()
        }
    }
    
    @IBAction func swipeRight(_ sender: AnyObject) {start()}
    @IBAction func swipeLeft(_ sender: AnyObject) {start()}
    @IBAction func swipeUp(_ sender: AnyObject) {start()}
    @IBAction func swipeDown(_ sender: AnyObject) {start()}
    
    // MARK: - View Loading and Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeDisplay.font = UIFont.monospacedDigitSystemFont(ofSize: 64, weight: UIFontWeightRegular)
        stopwatch = Stopwatch.init(delegate: self, duration: providedDuration)
        stopwatch?.clearTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Display Updating
    
    func displayInt(_ integer: Int) {timeDisplay.text = timeFormatter.formatTime(integer)}
    
    // MARK: - Convenience
    
    func start() {stopwatch?.startTimer()}
}

// MARK: - STViewController Extensions

extension STViewController: StopwatchDelegate {
    func updateDisplay(with integer: Int) {
        displayInt(integer)
    }
    
    func setButton(to buttonValue: ChangeButtonValues) {
        buttonStatus = buttonValue
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        UIView.performWithoutAnimation {
            self.changeButton.setTitle(buttonValue.text, for: UIControlState())
            self.changeButton.layoutIfNeeded()
        }
    }
    
    func timerDidStart() {soundController.playFirstSound()}
    
    func timerDidEnd() {soundController.playSecondSound()}
}
