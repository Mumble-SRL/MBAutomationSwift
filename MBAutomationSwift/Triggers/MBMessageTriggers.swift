//
//  MBMessagesTriggers.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 07/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBMessagesSwift

/// The triggers method
enum MBMessageTriggersMethod: Int {
    /// The trigger becomes valid if one of the triggers is valid
    case any
    /// The trigger becomes valid when all the triggers are valid
    case all
}

/// The triggers associated with a message
class MBMessageTriggers: NSObject {

    /// The method of the triggers
    let method: MBMessageTriggersMethod
    
    /// The triggers
    var triggers: [MBTrigger]
        
    /// Initializes a `MBMessageTriggers` object with a method and triggers
    init(method: MBMessageTriggersMethod,
         triggers: [MBTrigger]) {
        self.method = method
        self.triggers = triggers
    }
    
    /// Initializes a `MBMessageTriggers` object with the dictionary returned by the api
    convenience init(dictionary: [String: Any]) {
        let methodString = dictionary["method"] as? String
        var method: MBMessageTriggersMethod = .all
        if methodString == "all" {
            method = .all
        } else if methodString == "any" {
            method = .any
        }
        
        var triggers: [MBTrigger] = []
        if let triggersDictionaries = dictionary["triggers"] as? [[String: Any]] {
            triggers = triggersDictionaries.map({ MBAutomationMessagesManager.trigger(forDictionary: $0)
            })
        }
        
        self.init(method: method,
                  triggers: triggers)
    }
    
    /// If this trigger is valid, as defined by the trigger method
    /// - Parameters:
    ///   - message: the message that requested if this trigger is valid
    ///   - fromAppStartup: if this function is called from startup
    /// - Returns: If this trigger is valid
    func isValid(message: MBMessage, fromAppStartup: Bool) -> Bool {
        for trigger in triggers {
            switch method {
            case .any:
                if trigger.isValid(message: message,
                                   fromAppStartup: fromAppStartup) {
                    return true
                }
            case .all:
                if !trigger.isValid(message: message,
                                    fromAppStartup: fromAppStartup) {
                    return false
                }
            }
        }
        return method == .any ? false : true
    }
        
    // MARK: - Save & retrieve

    /// Initializes a `MBMessageTriggers` with the dictionary saved previously
    /// - Parameters:
    ///  - dictionary: The dictionary saved
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let methodInt = dictionary["method"] as? Int ?? 0
        let method = MBMessageTriggersMethod(rawValue: methodInt) ?? MBMessageTriggersMethod.all
        
        let triggersDictionaries = dictionary["triggers"] as? [[String: Any]]
        let triggers = triggersDictionaries?.map({ MBAutomationMessagesManager.trigger(fromJsonDictionary: $0) }) ?? []
        self.init(method: method, triggers: triggers)
    }

    /// Converts this trigger to a JSON dictionary to be saved
    func toJsonDictionary() -> [String: Any] {
        var dictionary: [String: Any] = ["method": method.rawValue]
        dictionary["triggers"] = triggers.map({$0.toJsonDictionary()})
        return dictionary
    }
    
    // MARK: - Update Triggers
    
    func updateTriggers(newTriggers: MBMessageTriggers) -> MBMessageTriggers {
        var updatedTriggers = [MBTrigger]()
        for newTrigger in newTriggers.triggers {
            if let trigger = triggers.first(where: { $0.id == newTrigger.id }) {
                let updatedTrigger = trigger.updatedTrigger(newTrigger: newTrigger)
                updatedTriggers.append(updatedTrigger)
            } else {
                updatedTriggers.append(newTrigger)
            }
        }
        self.triggers = updatedTriggers
        return self
    }
}
