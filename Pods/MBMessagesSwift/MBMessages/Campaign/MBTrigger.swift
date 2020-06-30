//
//  MBTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

/// A trigger associated with a campaign, if the campaign has triggers, the display of messages and push notification will be managed with the MBAutomation plugin
public class MBTrigger: NSObject {
    
    /// The id of the trigger
    let id: Int
    
    /// Initializes a trigger with the data passed
    init(id: Int) {
        self.id = id
    }
    
    /// Initializes a trigger with the dictionary returned by the api
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        self.init(id: id)
    }
}
