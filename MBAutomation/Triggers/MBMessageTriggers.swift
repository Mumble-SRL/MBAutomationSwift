//
//  MBMessagesTriggers.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 07/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

enum MBMessageTriggersMethod: Int {
    case any
    case all
}

class MBMessageTriggers: NSObject {

    let method: MBMessageTriggersMethod
    
    let triggers: [MBTrigger]
        
    init(method: MBMessageTriggersMethod,
         triggers: [MBTrigger]) {
        self.method = method
        self.triggers = triggers
    }
    
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
    
    func isValid(fromAppStartup: Bool) -> Bool {
        for trigger in triggers {
            switch method {
            case .any:
                if trigger.isValid(fromAppStartup: fromAppStartup) {
                    return true
                }
            case .all:
                if !trigger.isValid(fromAppStartup: fromAppStartup) {
                    return false
                }
            }
        }
        return true
    }
        
    //MARK: - Save & retrieve

    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let methodInt = dictionary["method"] as? Int ?? 0
        let method = MBMessageTriggersMethod(rawValue: methodInt) ?? MBMessageTriggersMethod.all
        
        let triggersDictionaries = dictionary["triggers"] as? [[String: Any]]
        let triggers = triggersDictionaries?.map({ MBAutomationMessagesManager.trigger(fromJsonDictionary: $0) }) ?? []
        self.init(method: method, triggers: triggers)
    }

    func toJsonDictionary() -> [String: Any] {
        var dictionary: [String: Any] = ["method": method.rawValue]
        dictionary["triggers"] = triggers.map({$0.toJsonDictionary()})
        return dictionary
    }
}
