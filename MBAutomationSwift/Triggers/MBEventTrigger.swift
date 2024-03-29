//
//  MBEventTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBMessagesSwift

/// An event trigger, this trigger becomes valid when an event happens n times
public class MBEventTrigger: MBTrigger {
    
    /// The event
    public let event: String
    
    /// The times the event needs to happen
    public let times: Int
    
    /// The metadata of the event
    public let metadata: [String: Any]?
    
    /// The date this trigger becomes true
    public var completionDate: Date?
    /// The number of times this event has happened
    public var numberOfTimes: Int?
        
    /// Initializes a `MBEventTrigger` with the parameters passed
    /// - Parameters:
    ///  - id: The id of the trigger
    ///  - event: The event
    ///  - times: Number of times the event needs to happen
    ///  - metadata: The metadata for this event
    init(id: String,
         event: String,
         times: Int,
         metadata: [String: Any]?) {
        self.event = event
        self.times = times
        self.metadata = metadata
        super.init(id: id, type: .event)
    }

    /// Initializes a `MBEventTrigger` with the dictionary returned by the api
    /// - Parameters:
    ///   - dictionary: the dictionary returned by the api
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let event = dictionary["event"] as? String ?? ""
        let times = dictionary["times"] as? Int ?? 1
        let metadata = dictionary["metadata"] as? [String: Any]

        self.init(id: id,
                  event: event,
                  times: times,
                  metadata: metadata)
    }

    /// Function called when an event happen
    /// - Returns: If the trigger has changed
    func eventHappened(event: MBAutomationEvent) -> Bool {
        var isTriggerEvent = false
        if event.event == self.event {
            if let metadata = event.metadata {
                if let triggerMetadata = self.metadata {
                    isTriggerEvent = NSDictionary(dictionary: metadata).isEqual(to: triggerMetadata)
                } else {
                    isTriggerEvent = metadata.isEmpty
                }
            } else {
                isTriggerEvent = true
            }
            
            if isTriggerEvent {
                if let numberOfTimes = numberOfTimes {
                    self.numberOfTimes = numberOfTimes + 1
                } else {
                    numberOfTimes = 1
                }
                if (self.numberOfTimes ?? 0) >= times {
                    completionDate = Date()
                }
                return true
            }
        }
        return false
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

    /// Initializes a `MBAppOpeningTrigger` with the dictionary saved previously
    /// - Parameters:
    ///  - dictionary: The dictionary saved
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let event = dictionary["event"] as? String ?? ""
        let times = dictionary["times"] as? Int ?? 0
        let metadata = dictionary["metadata"] as? [String: Any]
        
        self.init(id: id, event: event, times: times, metadata: metadata)
        
        if let completionDate = dictionary["completionDate"] as? TimeInterval {
            self.completionDate = Date(timeIntervalSince1970: completionDate)
        }
        self.numberOfTimes = dictionary["numberOfTimes"] as? Int
    }

    /// Converts this trigger to a JSON dictionary to be saved
    override func toJsonDictionary() -> [String: Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["event"] = event
        dictionary["times"] = times
        dictionary["metadata"] = metadata
        
        if let completionDate = completionDate {
            dictionary["completionDate"] = completionDate.timeIntervalSince1970
        }
        if let numberOfTimes = numberOfTimes {
            dictionary["numberOfTimes"] = numberOfTimes
        }
        return dictionary
    }
    
    // MARK: - Trigger Update
        
    override internal func updatedTrigger(newTrigger: MBTrigger) -> MBTrigger {
        guard let newEventTrigger = newTrigger as? MBEventTrigger else {
            return newTrigger
        }
        
        newEventTrigger.numberOfTimes = numberOfTimes
        newEventTrigger.completionDate = completionDate
        return newEventTrigger
    }
}
