//
//  MBInactiveUserTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBAudienceSwift

/// An inactive user trigger, this trigger becomes valid when the user has not openend the app for n days
public class MBInactiveUserTrigger: MBTrigger {
    
    /// The days that needs to pass to make this trigger valid
    public let days: Int
        
    /// Initializes a `MBInactiveUserTrigger` with the parameters passed
    /// - Parameters:
    ///  - id: The id of the trigger
    ///  - days:  The days that needs to pass to make this trigger valid
    init(id: String,
         days: Int) {
        self.days = days
        super.init(id: id, type: .inactiveUser)
    }

    /// Initializes a `MBInactiveUserTrigger` with the dictionary returned by the api
    /// - Parameters:
    ///   - dictionary: the dictionary returned by the api
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let days = dictionary["days"] as? Int ?? 0

        self.init(id: id,
                  days: days)
    }

    /// If the trigger is valid
    /// - Parameters:
    ///   - fromAppStartup: if this function is called from startup
    /// - Returns: If this trigger is valid
    override func isValid(fromAppStartup: Bool) -> Bool {
        guard fromAppStartup else {
            return false
        }
        let currentSession = MBAudience.currentSession()
        guard let currentDate = MBAudience.startSessionDate(forSession: currentSession),
            let lastSessionDate = MBAudience.startSessionDate(forSession: currentSession - 1) else {
            return false
        }
        let days = Calendar.current.dateComponents([.day], from: lastSessionDate, to: currentDate).day ?? 0
        return days >= self.days
    }

    // MARK: - Save & retrieve

    /// Initializes a `MBInactiveUserTrigger` with the dictionary saved previously
    /// - Parameters:
    ///  - dictionary: The dictionary saved
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let days = dictionary["days"] as? Int ?? 0
        self.init(id: id, days: days)
    }

    /// Converts this trigger to a JSON dictionary to be saved
    override func toJsonDictionary() -> [String: Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["days"] = days
        return dictionary
    }

}
