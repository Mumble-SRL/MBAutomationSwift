//
//  MBAutomationMessagesManager.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBMessagesSwift
import MBurgerSwift

class MBAutomationMessagesManager: MBTrigger {
    static var timer: Timer?
    
    //MARK: - Set triggers
    
    static func setTriggers(toMessages messages: inout [AnyObject]) {
        for message in messages where message is MBMessage {
            guard let message = message as? MBMessage else {
                continue
            }
            guard message.automationIsOn else {
                return
            }
            if let triggers = message.triggers as? [String: Any] {
                message.triggers = MBMessageTriggers(dictionary: triggers)
            }
        }
    }
    
    internal static func trigger(fromJsonDictionary dictionary: [String: Any]) -> MBTrigger {
        let typeInt = dictionary["type"] as? Int ?? MBTriggerType.unknown.rawValue
        let type = MBTriggerType(rawValue: typeInt) ?? MBTriggerType.unknown
        
        switch type {
        case .location:
            return MBLocationTrigger(fromJsonDictionary: dictionary)
        case .appOpening:
            return MBAppOpeningTrigger(fromJsonDictionary: dictionary)
        case .view:
            return MBViewTrigger(fromJsonDictionary: dictionary)
        case .inactiveUser:
            return MBInactiveUserTrigger(fromJsonDictionary: dictionary)
        case .event:
            return MBEventTrigger(fromJsonDictionary: dictionary)
        case .tagChange:
            return MBTagChangeTrigger(fromJsonDictionary: dictionary)
        case .unknown:
            return MBTrigger(fromJsonDictionary: dictionary)
        }
    }

    internal static func trigger(forDictionary dictionary: [String: Any]) -> MBTrigger {
        let type = dictionary["type"] as? String ?? ""
        
        switch type {
        case "location":
            return MBLocationTrigger(dictionary: dictionary)
        case "app_opening":
            return MBAppOpeningTrigger(dictionary: dictionary)
        case "view":
            return MBViewTrigger(dictionary: dictionary)
        case "inactive_user":
            return MBInactiveUserTrigger(dictionary: dictionary)
        case "event":
            return MBEventTrigger(dictionary: dictionary)
        case "tag_change":
            return MBTagChangeTrigger(dictionary: dictionary)
        default:
            return MBTrigger(dictionary: dictionary)
        }
    }
    
    //MARK: - Check triggers timer
        
    static func startMessagesTimer(time: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: true, block: { _ in
            checkMessages(fromStartup: false)
        })
    }
    
    static func eventHappened(event: MBAutomationEvent) {
        let savedMessages = self.savedMessages()
        guard savedMessages.count != 0 else {
            return
        }
        
        var somethingChanged = false
        for message in savedMessages {
            if let trigger = message.triggers as? MBMessageTriggers,
                let eventsTriggers = trigger.triggers.filter({ $0 is MBEventTrigger }) as? [MBEventTrigger] {
                for eventTrigger in eventsTriggers {
                    let triggerChanged = eventTrigger.eventHappened(event: event)
                    if triggerChanged {
                        somethingChanged = true
                    }
                }
            }
        }
        if somethingChanged {
            saveMessages(savedMessages, fromFetch: false)
        }
        checkMessages(fromStartup: false)
    }
    
    static func screenViewed(view: MBAutomationView) {
        MBAutomationMessagesViewManager.shared.screenViewed(view: view)
    }
    
    static func checkMessages(fromStartup: Bool) {
        let savedMessages = self.savedMessages()
        guard savedMessages.count != 0 else {
            return
        }
        var messagesToShow = [MBMessage]()
        for message in savedMessages {
            guard let triggers = message.triggers as? MBMessageTriggers else {
                continue
            }
            if triggers.isValid(fromAppStartup: true) {
                messagesToShow.append(message)
            }
        }
        if messagesToShow.count != 0 {
            let inAppMessages = messagesToShow.filter({ $0.type == .inAppMessage && $0.inAppMessage != nil })
            if inAppMessages.count != 0 {
                if let plugin = MBManager.shared.plugins.first(where: { $0 is MBMessages }) as? MBMessages {
                    MBInAppMessageManager.presentMessages(inAppMessages,
                                                          delegate: plugin.viewDelegate,
                                                          styleDelegate: plugin.styleDelegate,
                                                          ignoreShowedMessages: plugin.debug)
                }
            }
        }
    }
        
    //MARK: - Message saving
    
    static func saveMessages(_ messages: [MBMessage], fromFetch: Bool) {
        guard let messagesPath = messagesPath() else {
            return
        }
        
        let savedMessages = self.savedMessages()
        var messagesToSave: [MBMessage] = []
        if fromFetch {
            for message in messages {
                if let savedMessage = savedMessages.first(where: { $0.id == message.id }) {
                    messagesToSave.append(savedMessage)
                } else {
                    messagesToSave.append(message)
                }
            }
        } else {
            messagesToSave = messages
        }
        let jsonDictionaries = messagesToSave.map({ $0.toJsonDictionary() })
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionaries, options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        try? jsonString.write(toFile: messagesPath, atomically: true, encoding: .utf8)
    }

    static func savedMessages() -> [MBMessage] {
        guard let path = messagesPath() else {
            return []
        }
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            return []
        }
        guard let data = try? Data(contentsOf: URL.init(fileURLWithPath: path)) else {
            return []
        }
        guard let objects = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] else {
            return []
        }
        guard let unwrappedObjects = objects else {
            return []
        }
        return unwrappedObjects.compactMap({ MBMessage(fromJsonDictionary: $0) })
    }
    
    static func messagesPath() -> String? {
        let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("mb_automation_messages.json")
        return fileURL?.path
    }
    
}

class MBAutomationMessagesViewManager: NSObject {
    static let shared = MBAutomationMessagesViewManager()
    
    func screenViewed(view: MBAutomationView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(setViewTriggerCompleted(data:)), object: nil)
        let savedMessages = MBAutomationMessagesManager.savedMessages()
        guard savedMessages.count != 0 else {
            return
        }
        for message in savedMessages {
            if let trigger = message.triggers as? MBMessageTriggers,
                let viewTriggers = trigger.triggers.filter({ $0 is MBViewTrigger }) as? [MBViewTrigger] {
                for viewTrigger in viewTriggers {
                    let result = viewTrigger.screenViewed(view: view)
                    if result {
                        if (viewTrigger.numberOfTimes ?? 0) >= viewTrigger.times {
                            let index = trigger.triggers.index(of: viewTrigger) ?? 0
                            let data: [String : Any] = ["message": message.id,
                                                        "index": index]
                            if viewTrigger.secondsOnView != 0 {
                                perform(#selector(setViewTriggerCompleted(data:)), with: data, afterDelay: 5/*viewTrigger.secondsOnView*/)
                            } else {
                                setViewTriggerCompleted(data: data)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func setViewTriggerCompleted(data: [String: Any]) {
        print(data)
    }

}
