//
//  TimeAnnouncementPreference.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 2/11/18.
//  Copyright © 2018 Alan Kantz. All rights reserved.
//

import UIKit

struct TimeAnnouncementPreference: Codable {
    init() {
        if let dataFromDisk = defaults.data(forKey: K.announcementKey),
            let decodedDataFromDisk = try? decoder.decode(TimeAnnouncementPreference.self, from: dataFromDisk) {
            self.internalPreference = decodedDataFromDisk.internalPreference
        } else { print("Could not load announcement preference") }
    }
    
    var preference: Bool {
        get { return internalPreference ?? false }
        set { internalPreference = newValue }
    }
    
    private var internalPreference: Bool? {
        didSet { save() }
    }
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue.init(label: "preferences", qos: .utility)
    
    private func save() {
        queue.async {
            guard let encoded = try? self.encoder.encode(self) else {
                print("Could not save time announcement preference.")
                return
            }
            self.defaults.set(encoded, forKey: K.announcementKey)
        }
    }
    
    private enum CodingKeys: String, CodingKey { case internalPreference }
}
