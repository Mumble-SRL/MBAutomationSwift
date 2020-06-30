//
//  MBPushMessage.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

public class MBPushMessage: NSObject {
    /// The id of the push message
    public let id: String

    /// The title of the push message
    public let title: String

    /// The body of the push message
    public let body: String
    
    /// If the push notification was sent or not by the server
    public let sent: Bool

    /// Initializes a push message with the parameters passed
    init(id: String,
         title: String,
         body: String,
         sent: Bool) {
        self.id = id
        self.title = title
        self.body = body
        self.sent = sent
    }

    /// Initializes a message with the dictionary returned by the APIs
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        
        var title = ""
        var body = ""
        var sent = false
        
        if let payload = dictionary["payload"] as? [String: Any] {
            title = payload["title"] as? String ?? ""
            body = payload["body"] as? String ?? ""
            sent = payload["sent"] as? Bool ?? false
        }
        
        self.init(id: id,
                  title: title,
                  body: body,
                  sent: sent)
    }
}
