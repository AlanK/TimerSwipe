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
    var savedTimerList = STTimerList()
    
    // MARK: - Timer

    var duration = 3000
    var providedDuration: Int?
    var timeRemaining: Int?
    var startTime: Date?
    var currentTime: Date?
    var endTime: Date?
    var timer = Timer()
    var unlocked = true
    
    func setDuration() {
        duration = providedDuration ?? duration
    }
    
    func clearTimer() {
        unlocked = true
        timer.invalidate()
        timeRemaining = duration
        timeDisplay.text = timeFormatter.formatTime(timeRemaining!)
        
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        
        UIView.performWithoutAnimation {
            self.changeButton.setTitle("Change", for: UIControlState())
            self.changeButton.layoutIfNeeded()
        }
    }
    
    func startTimer() {
        guard unlocked else {
            return
        }
        unlocked = false
        startTime = Date.init()
        endTime = Date.init(timeInterval: (Double(duration)/100.0), since: startTime!)
        timer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector: #selector(STViewController.tick), userInfo: nil, repeats: true)
        soundController.playFirstSound()
        
        // Use performWithoutAnimation to prevent weird flashing as button text animates.
        
        UIView.performWithoutAnimation {
            self.changeButton.setTitle("Cancel", for: UIControlState())
            self.changeButton.layoutIfNeeded()
        }
    }

    func tick() {
        currentTime = Date.init()
        if currentTime! >= endTime! {
            clearTimer()
            soundController.playSecondSound()
        }
        else {
            let decimalOfDisplay = endTime!.timeIntervalSince(currentTime!) * 100
            timeDisplay.text = timeFormatter.formatTime(Int(decimalOfDisplay))
        }
    }
    
    // MARK: - Labels & Buttons

    
    @IBOutlet var timeDisplay: UILabel!
    @IBOutlet var changeButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func changeButton(_ sender: AnyObject) {
        switch unlocked {
        case true: self.navigationController?.popViewController(animated: true)
        case false: clearTimer()
        }
    }
    
    @IBAction func swipeRight(_ sender: AnyObject) {
        startTimer()
    }
    @IBAction func swipeLeft(_ sender: AnyObject) {
        startTimer()
    }
    @IBAction func swipeUp(_ sender: AnyObject) {
        startTimer()
    }
    @IBAction func swipeDown(_ sender: AnyObject) {
        startTimer()
    }
    
    // MARK: - View Loading and Other
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeDisplay.font = UIFont.monospacedDigitSystemFont(ofSize: 64, weight: UIFontWeightRegular)
        setDuration()
        clearTimer()
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
}
