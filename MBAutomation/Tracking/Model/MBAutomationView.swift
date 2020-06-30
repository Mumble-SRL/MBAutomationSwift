//
//  MBAutomationView.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

class MBAutomationView: NSObject {
    let id: Int?
    let view: String
    let metadata: [String: Any]?
    let timestamp: Date!
        
    init(view: String,
         metadata: [String: Any]? = nil) {
        self.id = nil
        self.view = view
        self.metadata = metadata
        self.timestamp = Date()
    }

    init(id: Int,
         view: String,
         metadata: [String: Any]?,
         timestamp: TimeInterval) {
        self.id = id
        self.view = view
        self.metadata = metadata
        self.timestamp = Date(timeIntervalSince1970: timestamp)
    }
}
