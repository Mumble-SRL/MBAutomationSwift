//
//  MBInactiveUserTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBAudienceSwift

public class MBInactiveUserTrigger: MBTrigger {
    public let days: Int
        
    init(id: String,
         days: Int) {
        self.days = days
        super.init(id: id, type: .inactiveUser)
    }

    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let days = dictionary["days"] as? Int ?? 0

        self.init(id: id,
                  days: days)
    }

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

    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let days = dictionary["days"] as? Int ?? 0
        self.init(id: id, days: days)
    }

    override func toJsonDictionary() -> [String: Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["days"] = days
        return dictionary
    }

}
