//
//  MBTagChangeTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBMessagesSwift

/// When a tag changes tells if this trigger has changed or has become invalid
internal enum MBTriggerChangedStatus {
    case unchanged
    case valid
    case invalid
}

/// The tag change operator
public enum MBTagChangeOperator: Int {
    /// The tag needs to be equal to the value of the trigger
    case equal
    /// The tag needs to be different to the value of the trigger
    case notEqual
}

/// A tag change trigger, fires when the specified tag changes and become equal/different from the value, based on `tagChangeOperator`
public class MBTagChangeTrigger: MBTrigger {
    
    /// The tag that needs to change
    public let tag: String
    
    /// The value of the tag
    public let value: String
    
    /// If the tag needs to be equal/different for this trigger to be activated
    public let tagChangeOperator: MBTagChangeOperator
    
    /// The date this trigger becomes true
    public var completionDate: Date?

    /// Initializes a `MBTagChangeTrigger` with the parameters passed
    /// - Parameters:
    ///  - id: The id of the trigger
    ///  - tag:  The tag that needs to change
    ///  - value: The value of the tag
    ///  - tagChangeOperator: If the tag needs to be equal/different for this trigger to be activated
    init(id: String,
         tag: String,
         value: String,
         tagChangeOperator: MBTagChangeOperator) {
        self.tag = tag
        self.value = value
        self.tagChangeOperator = tagChangeOperator
        super.init(id: id, type: .tagChange)
    }

    /// Initializes a `MBTagChangeTrigger` with the dictionary returned by the api
    /// - Parameters:
    ///   - dictionary: the dictionary returned by the api
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let tag = dictionary["tag"] as? String ?? ""
        let value = dictionary["value"] as? String ?? ""
        let operatorString = dictionary["operator"] as? String ?? ""
        let tagChangeOperator: MBTagChangeOperator = operatorString == "=" ? .equal : .notEqual
        self.init(id: id,
                  tag: tag,
                  value: value,
                  tagChangeOperator: tagChangeOperator)
    }

    /// Function called when a tag changes in MBAudience
    /// - Parameters:
    ///   - tag: The tag that has changed
    ///   - value: The new value, nil if the tag has been deleted
    /// - Returns: Returns the new status of the tag as `MBTriggerChangedStatus`
    func tagChanged(tag: String, value: String?) -> MBTriggerChangedStatus {
        guard tag == self.tag else {
            return .unchanged
        }
        
        let newValue = value ?? ""
        if tagChangeOperator == .equal {
            if newValue == self.value {
                self.completionDate = Date()
                return .valid
            } else {
                self.completionDate = nil
                return .invalid
            }
        } else if tagChangeOperator == .notEqual {
            if newValue != self.value {
                self.completionDate = Date()
                return .valid
            } else {
                self.completionDate = nil
                return .invalid
            }
        }
        
        return .unchanged
    }
    
    /// If the trigger is valid
    /// - Parameters:
    ///   - message: the message that requested if this trigger is valid
    ///   - fromAppStartup: if this function is called from startup
    /// - Returns: If this trigger is valid
    override func isValid(message: MBMessage, fromAppStartup: Bool) -> Bool {
        guard let completionDate = completionDate else {
            return false
        }
        
        return completionDate.timeIntervalSince1970 <= Date().timeIntervalSince1970
    }

    // MARK: - Save & retrieve

    /// Initializes a `MBTagChangeTrigger` with the dictionary saved previously
    /// - Parameters:
    ///  - dictionary: The dictionary saved
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let tag = dictionary["tag"] as? String ?? ""
        let value = dictionary["value"] as? String ?? ""
        let tagChangeOperatorInt = dictionary["tagChangeOperator"] as? Int ?? 0

        self.init(id: id,
                  tag: tag,
                  value: value,
                  tagChangeOperator: MBTagChangeOperator(rawValue: tagChangeOperatorInt) ?? .equal)
        
        if let completionDate = dictionary["completionDate"] as? TimeInterval {
            self.completionDate = Date(timeIntervalSince1970: completionDate)
        }
    }

    /// Converts this trigger to a JSON dictionary to be saved
    override func toJsonDictionary() -> [String: Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["tag"] = tag
        dictionary["value"] = value
        dictionary["tagChangeOperator"] = tagChangeOperator.rawValue
        if let completionDate = completionDate {
            dictionary["completionDate"] = completionDate.timeIntervalSince1970
        }

        return dictionary
    }

    // MARK: - Trigger Update
        
    override internal func updatedTrigger(newTrigger: MBTrigger) -> MBTrigger {
        guard let newTagChangeTrigger = newTrigger as? MBTagChangeTrigger else {
            return newTrigger
        }
        
        newTagChangeTrigger.completionDate = completionDate
        return newTagChangeTrigger
    }

}
