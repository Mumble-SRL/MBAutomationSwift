//
//  MBEventTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

public class MBEventTrigger: MBTrigger {
    public let event: String
    public let times: Int
    public let metadata: [String: Any]?
    
    public var completionDate: Date? // The date this trigger becomes true
    public var numberOfTimes: Int? // The number of times this event happens
        
    init(id: String,
         event: String,
         times: Int,
         metadata: [String: Any]?) {
        self.event = event
        self.times = times
        self.metadata = metadata
        super.init(id: id, type: .event)
    }

    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let event = dictionary["event_name"] as? String ?? ""
        let times = dictionary["times"] as? Int ?? 1
        let metadata = dictionary["metadata"] as? [String: Any]

        self.init(id: id,
                  event: event,
                  times: times,
                  metadata: metadata)
    }

    // Called when an evens happen, returns if the ttag has changed
    func eventHappened(event: MBAutomationEvent) -> Bool {
        var isTriggerEvent = false
        if event.event == self.event {
            if let metadata = event.metadata {
                if let triggerMetadata = self.metadata {
                    isTriggerEvent = NSDictionary(dictionary: metadata).isEqual(to: triggerMetadata)
                } else {
                    isTriggerEvent = false
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
    
    override func isValid(fromAppStartup: Bool) -> Bool {
        return completionDate != nil
    }

    //MARK: - Save & retrieve

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

    override func toJsonDictionary() -> [String : Any] {
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
}
