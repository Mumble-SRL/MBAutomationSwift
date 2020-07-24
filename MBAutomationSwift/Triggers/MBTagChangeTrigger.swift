//
//  MBTagChangeTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

public enum MBTagChangeOperator: Int {
    case equal
    case notEqual
}

public class MBTagChangeTrigger: MBTrigger {
    public let tag: String
    public let value: String
    
    public let tagChangeOperator: MBTagChangeOperator
    
    public var completionDate: Date? // The date this trigger becomes true

    init(id: String,
         tag: String,
         value: String,
         tagChangeOperator: MBTagChangeOperator) {
        self.tag = tag
        self.value = value
        self.tagChangeOperator = tagChangeOperator
        super.init(id: id, type: .tagChange)
    }

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

    func tagChanged(tag: String, value: String?) -> Bool {
        guard tag == self.tag else {
            return false
        }
        
        let newValue = value ?? ""
        if tagChangeOperator == .equal {
            if newValue == self.value {
                completionDate = Date()
                return true
            }
        } else if tagChangeOperator == .notEqual {
            if newValue != self.value {
                completionDate = Date()
                return true
            }
        }
        
        return false
    }
    
    override func isValid(fromAppStartup: Bool) -> Bool {
        return completionDate != nil
    }

    // MARK: - Save & retrieve

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

}
