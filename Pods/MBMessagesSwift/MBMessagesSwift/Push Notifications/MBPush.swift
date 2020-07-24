//
//  MBPush.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 21/04/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MPushSwift

/// Wrapper around MPush to access it from the messages plugin

class MBPush: NSObject {
    static var pushToken: String {
        set {
            MPush.token = newValue
        }
        get {
            return MPush.token
        }
    }
    
    static func registerDevice(deviceToken: Data,
                               success: (() -> Void)? = nil,
                               failure: ((_ error: Error?) -> Void)? = nil) {
        MPush.registerDevice(deviceToken: deviceToken, success: success, failure: failure)
    }
    
    static func register(toTopic topic: String,
                         success: (() -> Void)? = nil,
                         failure: ((_ error: Error?) -> Void)? = nil) {
        MPush.register(toTopic: topic, success: success, failure: failure)
    }
    
    static func register(toTopics topics: [String],
                         success: (() -> Void)? = nil,
                         failure: ((_ error: Error?) -> Void)? = nil) {
        MPush.register(toTopics: topics, success: success, failure: failure)
    }
    
    static func unregister(fromTopic topic: String,
                           success: (() -> Void)? = nil,
                           failure: ((_ error: Error?) -> Void)? = nil) {
        MPush.unregister(fromTopic: topic, success: success, failure: failure)
    }
    
    static func unregister(fromTopics topics: [String],
                           success: (() -> Void)? = nil,
                           failure: ((_ error: Error?) -> Void)? = nil) {
        MPush.unregister(fromTopics: topics, success: success, failure: failure)
    }
    
    static func unregisterFromAllTopics(success: (() -> Void)? = nil,
                                        failure: ((_ error: Error?) -> Void)? = nil) {
        MPush.unregisterFromAllTopics(success: success, failure: failure)
    }
    
    // TODO: messages analytics: handle api push arrives and push tap
}
