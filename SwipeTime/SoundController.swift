//
//  SoundController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 7/16/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import AVFoundation

/// Available audio cues
enum AudioCue: String {
    case start = "TS_short_in.aif"
    case end = "TS_short_out.aif"
    case die = "TS_short_warn.aif"
}

/// Handles sounds for the main view of the app
struct SoundController {
    /// Singleton `AVAudioSession`
    private let audioSession = AVAudioSession()
    // Initializing an AVAudioPlayer is failable, so these need to be optionals
    private var sounds = [AudioCue : AVAudioPlayer?]()
    
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
        
        // Initialize the audio players. Kinda silly how verbose this is
        sounds[.start] = initializePlayer(with: AudioCue.start.rawValue)
        sounds[.end] = initializePlayer(with: AudioCue.end.rawValue)
        sounds[.die] = initializePlayer(with: AudioCue.die.rawValue)
        // Configure audio session to mix with background music
        do {
            try audioSession.setCategory(AVAudioSessionCategoryAmbient, mode: AVAudioSessionModeDefault, options: [])
        }
        catch {print("Could not set AVAudioSession category, mode, or options: \(error)")}
    }
    
    /**
     Activate or deactivate the audio session
     
     When activating the audio session, it is nice to prepare the sounds proactively.
     - parameter active: Whether the audio session should be activated or deactivated
     */
    func setActive(_ active: Bool) {
        do {try audioSession.setActive(active)}
        catch {print("Could not activate/deactivate AVAudioSession: \(error)")}
        
        guard active else {return}
        for sound in sounds {
            sound.value?.prepareToPlay()
        }
    }
    
    /// Vibrate without playing a sound
    private func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /// Play the appropriate audio and vibration cue
    func play(_ cue: AudioCue) {
        guard let sound = sounds[cue], let audio = sound else {return}
        audio.play()
        vibrate()
        audio.prepareToPlay()
        
        guard cue == .die else {return}
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) {timer in
            self.vibrate()
        }
    }
}
