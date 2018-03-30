//
//  TimeAnnouncementPreference.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 2/11/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

/// Handles reading and writing a user preference: whether or not to announce time remaining when VoiceOver is enabled
struct TimeAnnouncementPreference: Codable {
    // MARK: Initializers
    
    init() {
        if let dataFromDisk = defaults.data(forKey: K.announcementKey),
            let decodedDataFromDisk = try? decoder.decode(TimeAnnouncementPreference.self, from: dataFromDisk) {
            self.internalPreference = decodedDataFromDisk.internalPreference
        } else { print("Could not load announcement preference") }
    }
    
    // MARK: Properties
    // Default to false if the user has never set a preference
    var preference: Bool {
        get { return internalPreference ?? false }
        set { internalPreference = newValue }
    }
    
    // The preference is trinary, so it remembers if the user has never set it
    private var internalPreference: Bool? {
        didSet { save() }
    }
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "preferences", qos: .utility)
    
    // MARK: Methods
    // Write the preference to disk on a utility queue
    private func save() {
        queue.async {
            guard let encoded = try? self.encoder.encode(self) else {
                print("Could not save time announcement preference.")
                return
            }
            self.defaults.set(encoded, forKey: K.announcementKey)
        }
    }
    
    // MARK: Weird Codable Hacking
    // Only encode `internalPreference`
    private enum CodingKeys: String, CodingKey { case internalPreference }
}
