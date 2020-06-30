//
//  MBAutomationEvent.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

class MBAutomationEvent: NSObject {
    let id: Int?
    let event: String
    let name: String?
    let metadata: [String: Any]?
    let timestamp: Date!

    init(event: String,
         name: String? = nil,
         metadata: [String: Any]? = nil) {
        self.id = nil
        self.event = event
        self.name = name
        self.metadata = metadata
        self.timestamp = Date()
    }
    
    init(id: Int,
         event: String,
         name: String?,
         metadata: [String: Any]?,
         timestamp: TimeInterval) {
        self.id = id
        self.event = event
        self.name = name
        self.metadata = metadata
        self.timestamp = Date(timeIntervalSince1970: timestamp)
    }

}
