//
//  MBTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

public enum MBTriggerType: Int {
    case location
    case appOpening
    case view
    case inactiveUser
    case event
    case tagChange
    case unknown
}

/// A trigger associated with a message, if the message has triggers, the display of messages and push notification will be managed with the MBAutomation plugin
public class MBTrigger: NSObject {
    
    /// The id of the trigger
    let id: String
    
    /// The type of trigger
    let type: MBTriggerType
        
    init(id: String, type: MBTriggerType) {
        self.id = id
        self.type = type
    }
    
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        self.init(id: id, type: .unknown)
    }
    
    func isValid(fromAppStartup: Bool) -> Bool {
        return false
    }
    
    // MARK: - Save & retrieve
    
    func toJsonDictionary() -> [String: Any] {
        return ["id": id,
                "type": type.rawValue]
    }

    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let type = dictionary["type"] as? Int ?? MBTriggerType.unknown.rawValue
        self.init(id: id, type: MBTriggerType(rawValue: type) ?? .unknown)
    }
}
