//
//  MBTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBMessagesSwift

/// The possible types for the trigger
public enum MBTriggerType: Int {
    /// Location trigger
    case location
    /// App opening trigger
    case appOpening
    /// View trigger
    case view
    /// Inactive user trigger
    case inactiveUser
    /// An event trigger
    case event
    /// A tag change trigger
    case tagChange
    /// An unknown trigger, used when the type is not recognized
    case unknown
}

/// A trigger associated with a message, if the message has triggers, the display of messages and push notification will be managed with the MBAutomation plugin
public class MBTrigger: NSObject {
    
    /// The id of the trigger
    let id: String
    
    /// The type of trigger
    let type: MBTriggerType
        
    /// Initializes a `MBTrigger` with the parameters passed
    /// - Parameters:
    ///  - id: The id of the trigger
    ///  - type:  The trigger type
    init(id: String, type: MBTriggerType) {
        self.id = id
        self.type = type
    }
    
    /// Initializes a `MBTrigger` with the dictionary returned by the api
    /// - Parameters:
    ///   - dictionary: the dictionary returned by the api
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        self.init(id: id, type: .unknown)
    }
    
    /// If the trigger is valid
    /// - Parameters:
    ///   - message: the message that requested if this trigger is valid
    ///   - fromAppStartup: if this function is called from startup
    /// - Returns: If this trigger is valid
    func isValid(message: MBMessage, fromAppStartup: Bool) -> Bool {
        return false
    }
    
    // MARK: - Save & retrieve
    
    /// Initializes a `MBTrigger` with the dictionary saved previously
    /// - Parameters:
    ///  - dictionary: The dictionary saved
    func toJsonDictionary() -> [String: Any] {
        return ["id": id,
                "type": type.rawValue]
    }

    /// Converts this trigger to a JSON dictionary to be saved
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let type = dictionary["type"] as? Int ?? MBTriggerType.unknown.rawValue
        self.init(id: id, type: MBTriggerType(rawValue: type) ?? .unknown)
    }
    
    /// Updates the trigger with the new infos
    /// By defaults no action is done
    internal func updatedTrigger(newTrigger: MBTrigger) -> MBTrigger {
        return newTrigger
    }
}

