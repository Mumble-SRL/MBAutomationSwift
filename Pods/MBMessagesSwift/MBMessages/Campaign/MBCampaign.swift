//
//  MBCampaign.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

/// The type of the campaign, in app message or push
public enum CampaignType {
    case inAppMessage
    case push
    
    static func campaignType(fromString campaignTypeString: String) -> CampaignType {
        if campaignTypeString == "message" {
            return .inAppMessage
        } else if campaignTypeString == "push" {
            return .push
        }
        return .inAppMessage
    }
}

/// This object represents a campaign from MBurger
public class MBCampaign: NSObject {
    
    /// The id of the campaign
    public let id: Int!
    
    /// The title of the campaign
    public let title: String!

    /// The description of the campaign
    public let campaignDescription: String!

    /// The type of the campaign
    public let type: CampaignType!
    
    /// If the type of the campaign is message, this is the in app message connected to the campaign
    public let message: MBInAppMessage?
    
    /// If the type of the campaign is push, this is the push message connected to the campaign
    public let push: MBPushMessage?
    
    /// The start date of the campaign
    public let startDate: Date
    
    /// The end date of the campaign
    public let endDate: Date

    /// If automation is on for this campaing
    public let automationIsOn: Bool

    public let triggers: [MBTrigger]?
    
    /// Initializes a campaign with the parameters passed
    init(id: Int,
         title: String,
         campaignDescription: String,
         type: CampaignType,
         message: MBInAppMessage? = nil,
         push: MBPushMessage? = nil,
         startDate: Date,
         endDate: Date,
         automationIsOn: Bool,
         triggers: [MBTrigger]?) {
        self.id = id
        self.title = title
        self.campaignDescription = campaignDescription
        self.type = type
        self.message = message
        self.push = push
        self.startDate = startDate
        self.endDate = endDate
        self.automationIsOn = automationIsOn
        self.triggers = triggers
    }
    
    /// Initializes a campaign with the dictionary returned by the APIs
    convenience init(dictionary: [String: Any]) {
        print(dictionary)
        
        let id = dictionary["id"] as? Int ?? 0
        let title = dictionary["title"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""
        
        let typeString = dictionary["type"] as? String ?? "message"
        let type = CampaignType.campaignType(fromString: typeString)

        var message: MBInAppMessage?
        var push: MBPushMessage?

        if let content = dictionary["content"] as? [String: Any] {
            if type == .inAppMessage {
                message = MBInAppMessage(dictionary: content)
            } else {
                push = MBPushMessage(dictionary: content)
            }
        }
        
        let startDateInt = dictionary["starts_at"] as? Int ?? 0
        let startDate = Date(timeIntervalSince1970: TimeInterval(startDateInt))
        
        let endDateInt = dictionary["ends_at"] as? Int ?? 0
        let endDate = Date(timeIntervalSince1970: TimeInterval(endDateInt))

        let automationIsOn = dictionary["automation"] as? Bool ?? false

        var triggers: [MBTrigger]?
        if let triggersDictionaries = dictionary["triggers"] as? [[String: Any]] {
            triggers = triggersDictionaries.map({ MBTrigger(dictionary: $0) })
        }
        
        self.init(id: id,
                  title: title,
                  campaignDescription: description,
                  type: type,
                  message: message,
                  push: push,
                  startDate: startDate,
                  endDate: endDate,
                  automationIsOn: automationIsOn,
                  triggers: triggers)
    }
}
