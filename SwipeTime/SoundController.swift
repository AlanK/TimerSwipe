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
    /// Singleton `AVAudioSession`
    private let audioSession = AVAudioSession()
    // Initializing an AVAudioPlayer is failable, so these need to be optionals
    private let timerDidStartCue: AVAudioPlayer?, timerDidEndCue: AVAudioPlayer?
    
    init() {
        /**
         Create an `AVAudioPlayer` from a filename
         - parameter file: A filename for a file in the main bundle
         - returns: An `AVAudioPlayer` configured to play the named file
         */
        func initializePlayer(with file: String) -> AVAudioPlayer? {
            guard let path = Bundle.main.path(forResource: file, ofType: nil), let player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path)) else {
                print("Could not initialize \(file).")
                return nil
            }
            return player
        }
        
        // Initialize the audio players
        timerDidStartCue = initializePlayer(with: Sound.shortWindStart.rawValue)
        timerDidEndCue = initializePlayer(with: Sound.shortWindEnd.rawValue)
        // Configure audio session to mix with background music
        do {
            try audioSession.setCategory(AVAudioSessionCategoryAmbient, mode: AVAudioSessionModeDefault, options: [])
        }
        catch {
            print("Could not set AVAudioSession category, mode, or options: \(error)")
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
        timerDidStartCue?.prepareToPlay()
        timerDidEndCue?.prepareToPlay()
    }
    
    /// Vibrate without playing a sound
    private func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /// Plays the "timer start" sound
    func playStartSound() {
        timerDidStartCue?.play()
        vibrate()
        timerDidStartCue?.prepareToPlay()
    }
    
    /// Plays the "timer end" sound
    func playEndSound() {
        timerDidEndCue?.play()
        vibrate()
        timerDidEndCue?.prepareToPlay()
     }
}
