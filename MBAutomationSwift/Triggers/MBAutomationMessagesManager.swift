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
import CoreLocation

class MBAutomationMessagesManager {
    static var timer: Timer?
        
    // MARK: - Set triggers
    
    static func setTriggers(toMessages messages: inout [AnyObject]) {
        for message in messages {
            guard let message = message as? MBMessage else {
                continue
            }
            guard message.automationIsOn else {
                continue
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
    
    // MARK: - Check triggers timer
        
    /// Starts the message check
    static func startMessagesTimer(time: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: true, block: { _ in
            checkMessages(fromStartup: false)
        })
    }
    
    /// Called when the time changes in MBAutomation calss
    static func messageTimerTimeChanged(time: TimeInterval) {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: true, block: { _ in
            checkMessages(fromStartup: false)
        })
    }

    // MARK: - Events
    
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
    
    // MARK: - Screen view

    static func screenViewed(view: MBAutomationView) {
        MBAutomationMessagesViewManager.shared.screenViewed(view: view)
    }
            
    // MARK: - Tag change

    static func tagChanged(tag: String, value: String?) {
        let savedMessages = self.savedMessages()
        guard savedMessages.count != 0 else {
            return
        }
        
        var somethingChanged = false
        for message in savedMessages {
            if let trigger = message.triggers as? MBMessageTriggers,
                let tagTriggers = trigger.triggers.filter({ $0 is MBTagChangeTrigger }) as? [MBTagChangeTrigger] {
                for tagTrigger in tagTriggers {
                    let triggerChangeStatus = tagTrigger.tagChanged(tag: tag, value: value)
                    if triggerChangeStatus != .unchanged {
                        somethingChanged = true
                    }
                    // If the tag has been invalidated cancel future pushes
                    // Can be used to manage abandoned cart
                    if triggerChangeStatus == .invalid {
                        if message.type == .push && message.sendAfterDays != 0 {
                            MBAutomationPushNotificationsManager.cancelPushNotification(forMessage: message)
                        }
                    }
                }
            }
        }
        if somethingChanged {
            saveMessages(savedMessages, fromFetch: false)
        }
        checkMessages(fromStartup: false)
    }

    // MARK: - Location updates

    static func locationDataUpdated(latitude: Double, longitude: Double) {
        let savedMessages = self.savedMessages()
        guard savedMessages.count != 0 else {
            return
        }
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let lastLocation = self.lastLocation()
        
        var somethingChanged = false
        for message in savedMessages {
            if let trigger = message.triggers as? MBMessageTriggers,
                let locationTriggers = trigger.triggers.filter({ $0 is MBLocationTrigger }) as? [MBLocationTrigger] {
                for locationTrigger in locationTriggers {
                    let triggerChanged = locationTrigger.locationDataUpdated(location: location, lastLocation: lastLocation)
                    if triggerChanged {
                        somethingChanged = true
                    }
                    if locationTrigger.afterDays != 0 {
                        self.checkMessagesAfterDelay(locationTrigger.afterDays)
                    }
                }
            }
        }
        if somethingChanged {
            saveMessages(savedMessages, fromFetch: false)
        }
        checkMessages(fromStartup: false)
        saveLocationAsLast(location: location)
    }
    
    internal static func lastLocation() -> CLLocationCoordinate2D? {
        let lastLocationLatKey = "com.mumble.mburger.automation.lastLocation.lat"
        let lastLocationLngKey = "com.mumble.mburger.automation.lastLocation.lng"
        let lastLat = UserDefaults.standard.double(forKey: lastLocationLatKey)
        let lastLng = UserDefaults.standard.double(forKey: lastLocationLngKey)
        guard lastLat != 0 && lastLng != 0 else {
            return nil
        }
        return CLLocationCoordinate2D.init(latitude: lastLat, longitude: lastLng)
    }
    
    internal static func saveLocationAsLast(location: CLLocationCoordinate2D) {
        let lastLocationLatKey = "com.mumble.mburger.automation.lastLocation.lat"
        let lastLocationLngKey = "com.mumble.mburger.automation.lastLocation.lng"
        UserDefaults.standard.set(location.latitude, forKey: lastLocationLatKey)
        UserDefaults.standard.set(location.longitude, forKey: lastLocationLngKey)
    }

    internal static func checkMessagesAfterDelay(_ afterDays: Int) {
        guard let date = Calendar.current.date(byAdding: .day, value: afterDays, to: Date()) else {
            return
        }
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(checkTimerFired), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc internal static func checkTimerFired() {
        checkMessages(fromStartup: false)
    }
    
    // MARK: - Messages check
    
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
            if message.repeatTimes > 0 {
                let hasAppOpeningTrigger = triggers.triggers.contains(where: { $0 is MBAppOpeningTrigger })
                if !(hasAppOpeningTrigger && fromStartup) { // If is app onening and from startup skip the check
                    if let savedTriggers = savedMessageTriggerDictionary(message: message) {
                        let triggersDictionary = NSDictionary(dictionary: triggers.toJsonDictionary())
                        let savedTriggersDictionary = NSDictionary(dictionary: savedTriggers)
                        if savedTriggersDictionary.isEqual(to: triggersDictionary as? [AnyHashable: Any] ?? [:]) {
                            continue
                        }
                    }
                }
                MBAutomationMessagesManager.saveMessageTrigger(message: message)
            }
            if triggers.isValid(message: message,
                                fromAppStartup: fromStartup) {
                messagesToShow.append(message)
            }
        }
        
        if messagesToShow.count != 0 {
            let inAppMessages = messagesToShow.filter({ $0.type == .inAppMessage && $0.inAppMessage != nil })
            if inAppMessages.count != 0 && UIApplication.shared.applicationState != .background {
                if let plugin = MBManager.shared.plugins.first(where: { $0 is MBMessages }) as? MBMessages {
                    MBInAppMessageManager.presentMessages(inAppMessages,
                                                          delegate: plugin.viewDelegate,
                                                          styleDelegate: plugin.styleDelegate,
                                                          ignoreShowedMessages: plugin.debug)
                }
            }
            
            let pushNotifications = messagesToShow.filter({ $0.type == .push && $0.push != nil })
            
            if pushNotifications.count != 0 {
                MBAutomationPushNotificationsManager.showPushNotifications(messages: pushNotifications)
            }
        }
    }
    
    private static func saveMessageTrigger(message: MBMessage) {
        guard let path = triggersPath(message: message) else {
            return
        }
        guard let triggers = message.triggers as? MBMessageTriggers else {
            return
        }
        let jsonDictionary = triggers.toJsonDictionary()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        try? jsonString.write(toFile: path, atomically: true, encoding: .utf8)
    }

    private static func savedMessageTriggerDictionary(message: MBMessage) -> [String: Any]? {
        guard let path = triggersPath(message: message) else {
            return nil
        }
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            return nil
        }
        guard let data = try? Data(contentsOf: URL.init(fileURLWithPath: path)) else {
            return nil
        }
        guard let objects = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return nil
        }
        guard let dictionary = objects as? [String: Any] else {
            return nil
        }
        return dictionary
    }
    
    // MARK: - Message saving
    
    static func saveMessages(_ messages: [MBMessage], fromFetch: Bool) {
        guard let messagesPath = messagesPath() else {
            return
        }
        
        let savedMessages = self.savedMessages()
        var messagesToSave: [MBMessage] = []
        if fromFetch {
            for message in messages {
                if let savedMessage = savedMessages.first(where: { $0.id == message.id }) {
                    if let triggers = savedMessage.triggers as? MBMessageTriggers,
                       let newTriggers = message.triggers as? MBMessageTriggers {
                        let updatedTriggers = triggers.updateTriggers(newTriggers: newTriggers)
                        savedMessage.triggers = updatedTriggers
                        savedMessage.sendAfterDays = message.sendAfterDays
                        savedMessage.repeatTimes = message.repeatTimes
                    }
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
        guard let objects = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return []
        }
        guard let dictionaries = objects as? [[String: Any]] else {
            return []
        }
        return dictionaries.compactMap({ MBMessage(fromJsonDictionary: $0) })
    }
    
    static func messagesPath() -> String? {
        let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("mb_automation_messages.json")
        return fileURL?.path
    }
    
    static func triggersPath(message: MBMessage) -> String? {
        let fileName = "mb_automation_messages_" + String(message.id) + "_triggers.json"
        let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(fileName)
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
        
        var somethingChanged = false
        for message in savedMessages {
            if let trigger = message.triggers as? MBMessageTriggers,
                let viewTriggers = trigger.triggers.filter({ $0 is MBViewTrigger }) as? [MBViewTrigger] {
                for viewTrigger in viewTriggers {
                    let result = viewTrigger.screenViewed(view: view)
                    if result {
                        somethingChanged = true
                        if (viewTrigger.numberOfTimes ?? 0) >= viewTrigger.times {
                            let index = trigger.triggers.firstIndex(of: viewTrigger) ?? 0
                            let data: [String: Any] = ["message": message.id,
                                                        "index": index]
                            if viewTrigger.secondsOnView != 0 {
                                perform(#selector(setViewTriggerCompleted(data:)), with: data, afterDelay: viewTrigger.secondsOnView)
                            } else {
                                setViewTriggerCompleted(data: data)
                            }
                        }
                    }
                }
            }
        }
        
        if somethingChanged {
            MBAutomationMessagesManager.saveMessages(savedMessages, fromFetch: false)
        }
    }
    
    @objc private func setViewTriggerCompleted(data: [String: Any]) {
        guard let id = data["message"] as? Int,
            let triggerIndex = data["index"] as? Int else {
            return
        }
        let savedMessages = MBAutomationMessagesManager.savedMessages()
        guard let message = savedMessages.first(where: { $0.id == id }) else {
            return
        }
        guard let messageTriggers = message.triggers as? MBMessageTriggers else {
            return
        }
        
        let triggers = messageTriggers.triggers
        guard triggerIndex < triggers.count else {
            return
        }
        guard let trigger = triggers[triggerIndex] as? MBViewTrigger else {
            return
        }
        trigger.setCompleted()
        MBAutomationMessagesManager.saveMessages(savedMessages, fromFetch: false)
        MBAutomationMessagesManager.checkMessages(fromStartup: false)
    }

}
