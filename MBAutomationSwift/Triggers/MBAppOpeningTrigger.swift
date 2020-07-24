//
//  MBAppOpeningTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBAudienceSwift

/// A trigger that becomes true if the app is opened n times
public class MBAppOpeningTrigger: MBTrigger {
    
    /// The times that needs to be opened in order for this trigger to become valid
    public let times: Int
    
    /// Initializes a `MBAppOpeningTrigger` with a trigger id and the times
    /// - Parameters:
    ///   - id: the id of the trigger
    ///   - times: the times the app needs to be opened in order for this trigger to become valid
    init(id: String,
         times: Int) {
        self.times = times
        super.init(id: id, type: .appOpening)
    }

    /// Initializes a `MBAppOpeningTrigger` with the dictionary returned by the api
    /// - Parameters:
    ///   - dictionary: the dictionary returned by the api
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let times = dictionary["times"] as? Int ?? 0

        self.init(id: id,
                  times: times)
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
        return currentSession >= times
    }

    // MARK: - Save & retrieve

    /// Initializes a `MBAppOpeningTrigger` with the dictionary saved previously
    /// - Parameters:
    ///  - dictionary: The dictionary saved
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let times = dictionary["times"] as? Int ?? 0
        self.init(id: id, times: times)
    }
    
    /// Converts this trigger to a JSON dictionary to be saved
    override func toJsonDictionary() -> [String: Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["times"] = times
        return dictionary
    }
}
