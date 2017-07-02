//
//  SoundController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import AVFoundation

/// Handles sounds for the main view of the app
struct SoundController {
    /// Singleton AVAudioSession
    private let audioSession = AVAudioSession()
    private let startSound: AVAudioPlayer?, endSound: AVAudioPlayer?
    
    init() {
       // Configure audio session to mix with background music
        do {
            try audioSession.setCategory(AVAudioSessionCategoryAmbient, mode: AVAudioSessionModeDefault, options: [])
        }
        catch {
            print("Could not set AVAudioSession category, mode, route sharing, or options: \(error)")
        }
        // Initialize sounds
        if let startPath = Bundle.main.path(forResource: AudioCue.start.rawValue, ofType: nil) {
            startSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: startPath))
        } else {
            startSound = nil
            print("Could not initialize startSound.")
        }
        if let endPath = Bundle.main.path(forResource: AudioCue.end.rawValue, ofType: nil) {
            endSound  = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: endPath))
        } else {
            endSound = nil
            print("Could not initialize endSound.")
        }
    }
    
    /**
     Activate or deactivate the audio session
     
     When activating the audio session, it is nice to prepare the sounds proactively.
     
     - parameter active: Whether the audio session should be activated or deactivated
     */
    func setActive(_ active: Bool) {
        do {
            try audioSession.setActive(active)
        }
        catch {
            print("Could not activate/deactivate AVAudioSession: \(error)")
        }
        guard active else {return}
        startSound?.prepareToPlay()
        endSound?.prepareToPlay()
    }
    
    /// Vibrate without playing a sound
    private func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /// Plays the "timer start" sound
    func playStartSound() {
        startSound?.play()
        vibrate()
        startSound?.prepareToPlay()
    }
    
    /// Plays the "timer end" sound
    func playEndSound() {
        endSound?.play()
        vibrate()
        endSound?.prepareToPlay()
     }
}
