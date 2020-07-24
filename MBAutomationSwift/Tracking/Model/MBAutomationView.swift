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
    
    func apiDictionary() -> [String: Any] {
        var apiDictionary: [String: Any] = ["view": view,
                                            "timestamp": Int(timestamp.timeIntervalSince1970)]
        if let metadata = metadata {
            if let data = try? JSONSerialization.data(withJSONObject: metadata, options: JSONSerialization.WritingOptions(rawValue: 0)) {
                let metadataString = String.init(data: data, encoding: .utf8)
                apiDictionary["metadata"] = metadataString
            }
        }
        return apiDictionary
    }
}
