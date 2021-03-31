//
//  MBPushMessage.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import Foundation

/// A push message
public class MBPushMessage: NSObject {
    /// The id of the push message
    public let id: String

    /// The title of the push message
    public let title: String

    /// The body of the push message
    public let body: String
    
    /// The push notification badge value
    public let badge: Int?

    /// The push notification custom sound
    public let sound: String?

    /// The push notification launch image
    public let launchImage: String?

    /// Additional data for push notifications
    public let userInfo: [String: Any]?

    /// If the push notification was sent or not by the server
    public let sent: Bool

    /// Initializes a push message with the parameters passed
    public init(id: String,
                title: String,
                body: String,
                badge: Int?,
                sound: String?,
                launchImage: String?,
                userInfo: [String: Any]?,
                sent: Bool) {
        self.id = id
        self.title = title
        self.body = body
        self.badge = badge
        self.sound = sound
        self.launchImage = launchImage
        self.userInfo = userInfo
        self.sent = sent
    }

    /// Initializes a message with the dictionary returned by the APIs
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        
        var title = ""
        var body = ""
        var sent = false
        var badge: Int?
        var sound: String?
        var launchImage: String?
        var userInfo: [String: Any]?
        
        if let payload = dictionary["payload"] as? [String: Any] {
            title = payload["title"] as? String ?? ""
            body = payload["body"] as? String ?? ""
            sent = payload["sent"] as? Bool ?? false
            badge = payload["badge"] as? Int
            sound = payload["sound"] as? String
            launchImage = payload["launch-image"] as? String
            userInfo = payload["custom"] as? [String: Any]
        }
        
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
