//
//  MBPlugin.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 27/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation
import UIKit

/// Block executed at startup
public typealias MBApplicationStartupBlock = (_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?, _ completionBlock: (() -> Void)?) -> Void

/// A plugin that can be attached to add more functionalities to MBurger.
public protocol MBPlugin {
    
    /// The key used in the user dictionary, used to retrieve and set the data.
    var userKey: String? { get }
    
    /// Returns a object that will be inserted in the pluginsObjects property of the user.
    /// - Parameters:
    ///   - response: The response to read data from.
    func object(forUserResponse response: [String: Any]) -> Any?
    
    /// Order of the application startup block
    var applicationStartupOrder: Int { get }
    
    /// Application startup block
    func applicationStartupBlock() -> MBApplicationStartupBlock?
    
    /// Function called by MBurger when new location data is available, used to synchronize audience location with automated messages
    /// - Parameters:
    ///   - latitude: The new latitude.
    ///   - longitude: The new longitude.
    func locationDataUpdated(latitude: Double, longitude: Double)
    
    /// Function called by MBAudience when a tatg changes, used to synchronize audience with automated messages
    /// - Parameters:
    ///   - tag: The tag that changed.
    ///   - value: The value that changed.
    func tagChanged(tag: String, value: String?)

    /// Function called by MBurger when messages are received, used to sync MBMessages with MBAutomation
    /// - Parameters:
    ///   - messages: Messages received.
    ///   - fromStartup: If the messages are being retrieved at startup.
    func messagesReceived(messages: inout [AnyObject], fromStartup: Bool)
}

/// Default values for plugin protocol
public extension MBPlugin {
    
    /// The default value for the user key is nil
    var userKey: String? {
        return nil
    }
    
    /// The default value for the object in user response is nil
    func object(forUserResponse response: [String: Any]) -> Any? {
        return nil
    }
    
    /// Default value for the startup order = -1
    var applicationStartupOrder: Int {
        return -1
    }

    /// Default value for the startup block = nil
    func applicationStartupBlock() -> MBApplicationStartupBlock? {
        return nil
    }
    
    /// Default implementation for tag change: empty, no action needed
    func tagChanged(tag: String, value: String?) {}

    /// Default implementation for locationDataUpdated: empty, no action needed
    func locationDataUpdated(latitude: Double, longitude: Double) { }
    
    /// Default implementation for messages retreival: empty, no action needed
    func messagesReceived(messages: inout [AnyObject], fromStartup: Bool) { }
}
