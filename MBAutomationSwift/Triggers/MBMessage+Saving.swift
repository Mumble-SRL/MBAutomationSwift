//
//  MBMessage+Saving.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 07/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBMessagesSwift

extension MBMessage {
    func toJsonDictionary() -> [String: Any] {
        var dictionary: [String: Any] = ["id": id,
                                         "title": title,
                                         "messageDescription": messageDescription,
                                         "type": type.rawValue,
                                         "createdAt": createdAt.timeIntervalSince1970,
                                         "sendAfterDays": sendAfterDays,
                                         "repeatTimes": repeatTimes,
                                         "automationIsOn": automationIsOn]
        if let startDate = startDate {
            dictionary["startDate"] = startDate.timeIntervalSince1970
        }
        
        if let endDate = endDate {
            dictionary["endDate"] = endDate.timeIntervalSince1970
        }
        
        if let inAppMessage = inAppMessage {
            dictionary["inAppMessage"] = inAppMessage.toJsonDictionary()
        }
        
        if let push = push {
            dictionary["push"] = push.toJsonDictionary()
        }

        if let triggers = triggers as? MBMessageTriggers {
            dictionary["triggers"] = triggers.toJsonDictionary()
        }
        
        return dictionary
    }
    
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let title = dictionary["title"] as? String ?? ""
        let messageDescription = dictionary["messageDescription"] as? String ?? ""
        let typeInt = dictionary["type"] as? Int ?? 0
        let creationDate = dictionary["createdAt"] as? TimeInterval ?? 0
        let startDateInterval = dictionary["startDate"] as? TimeInterval
        let endDateInterval = dictionary["endDate"] as? TimeInterval
        let sendAfterDays = dictionary["sendAfterDays"] as? Int ?? 0
        let repeatTimes = dictionary["repeatTimes"] as? Int ?? 0
        let automationIsOn = dictionary["automationIsOn"] as? Bool ?? false

        var startDate: Date?
        var endDate: Date?
        var inAppMessage: MBInAppMessage?
        var push: MBPushMessage?
        var triggers: MBMessageTriggers?
        
        if let startDateInterval = startDateInterval {
            startDate = Date(timeIntervalSince1970: startDateInterval)
        }
        
        if let endDateInterval = endDateInterval {
            endDate = Date(timeIntervalSince1970: endDateInterval)
        }

        if let inAppMessageDictionary = dictionary["inAppMessage"] as? [String: Any] {
            inAppMessage = MBInAppMessage(fromJsonDictionary: inAppMessageDictionary)
        }
        
        if let pushDictionary = dictionary["push"] as? [String: Any] {
            push = MBPushMessage(fromJsonDictionary: pushDictionary)
        }

        if let triggersDictionary = dictionary["triggers"] as? [String: Any] {
            triggers = MBMessageTriggers(fromJsonDictionary: triggersDictionary)
        }
        
        self.init(id: id,
                  title: title,
                  messageDescription: messageDescription,
                  type: MessageType(rawValue: typeInt) ?? .inAppMessage,
                  inAppMessage: inAppMessage,
                  push: push,
                  createdAt: Date(timeIntervalSince1970: creationDate),
                  startDate: startDate,
                  endDate: endDate,
                  automationIsOn: automationIsOn,
                  sendAfterDays: sendAfterDays,
                  repeatTimes: repeatTimes,
                  triggers: triggers)
    }
}

extension MBInAppMessage {
    func toJsonDictionary() -> [String: Any] {
        var dictionary: [String: Any] =  ["id": id ?? "",
                                          "style": (style ?? .bannerTop).rawValue,
                                          "isBlocking": isBlocking,
                                          "duration": duration ?? 0]
        if let title = title {
            dictionary["title"] = title
        }
        if let titleColor = titleColor {
            dictionary["titleColor"] = titleColor.toHexString()
        }
        if let body = body {
            dictionary["body"] = body
        }
        if let bodyColor = bodyColor {
            dictionary["bodyColor"] = bodyColor.toHexString()
        }
        if let image = image {
            dictionary["image"] = image
        }
        if let backgroundColor = backgroundColor {
            dictionary["backgroundColor"] = backgroundColor.toHexString()
        }
        if let buttons = buttons {
            dictionary["buttons"] = buttons.map({ $0.toJsonDictionary() })
        }

        return dictionary
    }
    
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let styleInt = dictionary["style"] as? Int ?? 0
        let isBlocking = dictionary["isBlocking"] as? Bool ?? false
        let duration = dictionary["duration"] as? TimeInterval ?? -1
        
        let title = dictionary["title"] as? String
        
        var titleColor: UIColor?
        if let titleColorString = dictionary["titleColor"] as? String {
            titleColor = UIColor(hexString: titleColorString)
        }

        let body = dictionary["body"] as? String
        
        var bodyColor: UIColor?
        if let bodyColorString = dictionary["bodyColor"] as? String {
            bodyColor = UIColor(hexString: bodyColorString)
        }
        
        let image = dictionary["image"] as? String
        
        var backgroundColor: UIColor?
        if let backgroundColorString = dictionary["backgroundColor"] as? String {
            backgroundColor = UIColor(hexString: backgroundColorString)
        }

        var buttons: [MBInAppMessageButton]?
        if let buttonsFromDict = dictionary["buttons"] as? [[String: Any]] {
            buttons = buttonsFromDict.map({ MBInAppMessageButton.init(fromJsonDictionary: $0) })
        }
        
        self.init(id: id,
                  style: MBInAppMessageStyle(rawValue: styleInt) ?? .bannerTop,
                  isBlocking: isBlocking,
                  duration: duration,
                  title: title,
                  titleColor: titleColor,
                  body: body,
                  bodyColor: bodyColor,
                  image: image,
                  backgroundColor: backgroundColor,
                  buttons: buttons)
    }
}

extension MBInAppMessageButton {
    func toJsonDictionary() -> [String: Any] {
        var dictionary: [String: Any] = ["title": title ?? "",
                                         "linkType": (linkType ?? .link).rawValue]
        if let link = link {
            dictionary["link"] = link
        }
        if let titleColor = titleColor {
            dictionary["titleColor"] = titleColor.toHexString()
        }
        if let backgroundColor = backgroundColor {
            dictionary["backgroundColor"] = backgroundColor.toHexString()
        }

        if let sectionId = sectionId {
            dictionary["sectionId"] = sectionId
        }
        
        if let blockId = blockId {
            dictionary["blockId"] = blockId
        }

        return dictionary
    }
    
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let title = dictionary["title"] as? String ?? ""
        let link = dictionary["link"] as? String
        let linkTypeInt = dictionary["linkType"] as? Int ?? 0
        var titleColor: UIColor?
        if let titleColorString = dictionary["titleColor"] as? String {
            titleColor = UIColor(hexString: titleColorString)
        }

        var backgroundColor: UIColor?
        if let backgroundColorString = dictionary["backgroundColor"] as? String {
            backgroundColor = UIColor(hexString: backgroundColorString)
        }

        let sectionId = dictionary["sectionId"] as? Int
        let blockId = dictionary["blockId"] as? Int

        self.init(title: title,
                  titleColor: titleColor,
                  backgroundColor: backgroundColor,
                  link: link,
                  linkType: MBInAppMessageButtonLinkType(rawValue: linkTypeInt) ?? .link,
                  sectionId: sectionId,
                  blockId: blockId)
    }
}

extension MBPushMessage {
    func toJsonDictionary() -> [String: Any] {
        var jsonDictionary: [String: Any] = ["id": id,
                                             "title": title,
                                             "body": body,
                                             "sent": sent]
        if let badge = badge {
            jsonDictionary["badge"] = badge
        }
        if let sound = sound {
            jsonDictionary["sound"] = sound
        }
        if let launchImage = launchImage {
            jsonDictionary["launchImage"] = launchImage
        }
        if let userInfo = userInfo {
            jsonDictionary["userInfo"] = userInfo
        }

        return jsonDictionary
    }
    
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let title = dictionary["title"] as? String ?? ""
        let body = dictionary["body"] as? String ?? ""
        let sent = dictionary["sentt"] as? Bool ?? false
        let badge = dictionary["badge"] as? Int
        let sound = dictionary["sound"] as? String
        let launchImage = dictionary["launchImage"] as? String
        let userInfo = dictionary["userInfo"] as? [String: Any]
        self.init(id: id,
                  title: title,
                  body: body,
                  badge: badge,
                  sound: sound,
                  launchImage: launchImage,
                  userInfo: userInfo,
                  sent: sent)
    }
}

private extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format: "#%06x", rgb)
    }
    
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            if #available(iOS 13, *) {
                scanner.currentIndex = hexString.index(after: hexString.startIndex)
            } else {
                scanner.scanLocation = 1
            }
        }
        
        var color: UInt32 = 0
        if #available(iOS 13, *) {
            var color64: UInt64 = 0
            scanner.scanHexInt64(&color64)
            color = UInt32(color64)
        } else {
            scanner.scanHexInt32(&color)
        }

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

}
