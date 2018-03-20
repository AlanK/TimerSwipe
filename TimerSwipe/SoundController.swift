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
    case startCue = "TS_short_in.aif"
    case endCue = "TS_short_out.aif"
}

/// Handles sounds for the main view of the app
struct SoundController {
    // MARK: Dependencies
    
    private let audioSession: AVAudioSession
    
    // MARK: Initalizers
    
    init(audioSession: AVAudioSession = AVAudioSession.sharedInstance()) {
        self.audioSession = audioSession
        
        /**
         Create an `AVAudioPlayer` from a filename
         - parameter cue: An audio cue
         - returns: An `AVAudioPlayer` configured to play the audio cue
         */
        func newPlayer(_ cue: AudioCue) -> AVAudioPlayer? {
            guard let path = Bundle.main.path(forResource: cue.rawValue, ofType: nil) else { return nil }
            return try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        }
        
        // Initialize the audio players
        audioPlayers = [.startCue : newPlayer(.startCue),
                        .endCue : newPlayer(.endCue)]
        
        // Configure audio session to mix with background music
        do { try audioSession.setCategory(AVAudioSessionCategoryAmbient, mode: AVAudioSessionModeDefault, options: []) }
        catch { print("Could not set AVAudioSession category, mode, or options: \(error)") }
    }
    
    // MARK: Properties
    
    private let audioPlayers: [AudioCue : AVAudioPlayer?]

    // MARK: Methods
    /**
     Activate or deactivate the audio session
     - parameter active: Whether the audio session should be activated or deactivated
     */
    func setActive(_ active: Bool) {
        do { try audioSession.setActive(active) }
        catch { print("Could not setActive(\(active)) AVAudioSession: \(error)") }
        
        // When activating the audio session, it is nice to prepare the sounds proactively.
        guard active else { return }
        for audioPlayer in audioPlayers { audioPlayer.value?.prepareToPlay() }
    }
    
    /**
     Play the appropriate audio and vibration cue
     - parameter cue: Which audio cue should play
     */
    func play(_ cue: AudioCue) {
        /// Vibrate without playing a sound
        func vibrate() { AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) }
        
        guard let audioPlayer = audioPlayers[cue] else {return}
        audioPlayer?.play()
        vibrate()
        audioPlayer?.prepareToPlay()
    }
}
