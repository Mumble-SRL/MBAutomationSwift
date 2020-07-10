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

    override func isValid(fromAppStartup: Bool) -> Bool {
        return true
    }

    //MARK: - Save & retrieve

    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let tag = dictionary["tag"] as? String ?? ""
        let value = dictionary["value"] as? String ?? ""
        let tagChangeOperatorInt = dictionary["tagChangeOperator"] as? Int ?? 0
        self.init(id: id,
                  tag: tag,
                  value: value,
                  tagChangeOperator: MBTagChangeOperator(rawValue: tagChangeOperatorInt) ?? .equal)
    }

    override func toJsonDictionary() -> [String : Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["tag"] = tag
        dictionary["value"] = value
        dictionary["tagChangeOperator"] = tagChangeOperator.rawValue
        
        return dictionary
    }

}
