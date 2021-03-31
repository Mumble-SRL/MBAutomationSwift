//
//  MBMessage.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

/// The type of message, in-app message or push
@objc public enum MessageType: Int {
    /// An in-app message
    case inAppMessage
    
    /// A push message
    case push
    
    /// Converts a string, tipically coming from the api, to a `MessageType`
    static func messageType(fromString messageTypeString: String) -> MessageType {
        if messageTypeString == "inApp" {
            return .inAppMessage
        } else if messageTypeString == "push" {
            return .push
        }
        return .inAppMessage
    }
}

/// This object represents a message from MBurger
@objc public class MBMessage: NSObject {
    
    /// The id of the message
    public let id: Int
    
    /// The title of the message
    public let title: String

    /// The description of the message
    public let messageDescription: String

    /// The type of message
    public let type: MessageType
    
    /// If the type of the message is in-app message, this is the in app message connected to the message
    public let inAppMessage: MBInAppMessage?
    
    /// If the type of the message is push, this is the push message connected to the message
    public let push: MBPushMessage?
    
    /// The date of creation of the message
    public let createdAt: Date

    /// The start date of the message
    public let startDate: Date
    
    /// The end date of the message
    public let endDate: Date

    /// If automation is on for this message
    public let automationIsOn: Bool

    /// The number of days to wait to show the message
    public var sendAfterDays: Int
    
    /// The number of times this message needs to be repeated
    public var repeatTimes: Int

    /// The triggers for the messages
    public var triggers: Any?
    
    /// Initializes a message with the parameters passed
    public init(id: Int,
                title: String,
                messageDescription: String,
                type: MessageType,
                inAppMessage: MBInAppMessage? = nil,
                push: MBPushMessage? = nil,
                createdAt: Date,
                startDate: Date,
                endDate: Date,
                automationIsOn: Bool,
                sendAfterDays: Int,
                repeatTimes: Int,
                triggers: Any?) {
        self.id = id
        self.title = title
        self.messageDescription = messageDescription
        self.type = type
        self.inAppMessage = inAppMessage
        self.push = push
        self.createdAt = createdAt
        self.startDate = startDate
        self.endDate = endDate
        self.automationIsOn = automationIsOn
        self.sendAfterDays = sendAfterDays
        self.repeatTimes = repeatTimes
        self.triggers = triggers
    }
    
    /// Initializes a message with the dictionary returned by the APIs
    @objc public convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let title = dictionary["title"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""
        
        let typeString = dictionary["type"] as? String ?? "message"
        let type = MessageType.messageType(fromString: typeString)

        var inAppMessage: MBInAppMessage?
        var push: MBPushMessage?

        if let content = dictionary["content"] as? [String: Any] {
            if type == .inAppMessage {
                inAppMessage = MBInAppMessage(dictionary: content)
            } else {
                push = MBPushMessage(dictionary: content)
            }
        }
        
        let createdDateInt = dictionary["created_at"] as? Int ?? 0
        let createdDate = Date(timeIntervalSince1970: TimeInterval(createdDateInt))

        let startDateInt = dictionary["starts_at"] as? Int ?? 0
        let startDate = Date(timeIntervalSince1970: TimeInterval(startDateInt))
        
        let endDateInt = dictionary["ends_at"] as? Int ?? 0
        let endDate = Date(timeIntervalSince1970: TimeInterval(endDateInt))

        let automationIsOn = dictionary["automation"] as? Bool ?? false
        
        let triggers = dictionary["triggers"] as? [String: Any]
        
        let sendAfterDays = dictionary["send_after_days"] as? Int ?? 0
        let repeatTimes = dictionary["repeat"] as? Int ?? 0
        
        self.init(id: id,
                  title: title,
                  messageDescription: description,
                  type: type,
                  inAppMessage: inAppMessage,
                  push: push,
                  createdAt: createdDate,
                  startDate: startDate,
                  endDate: endDate,
                  automationIsOn: automationIsOn,
                  sendAfterDays: sendAfterDays,
                  repeatTimes: repeatTimes,
                  triggers: triggers)
    }
}
