//
//  MBAutomation.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBurgerSwift
import MBMessagesSwift

public class MBAutomation: NSObject, MBPlugin {
    
    /// If tracking is enabled for this plugin, if this is false all events and views will not be saved and sent to the server
    var trackingEnabled: Bool = true
    
    /// Initializes the plugin, if trackViewsAutomatically if yes the views are tracked automatically. It uses method swizzling to track automatically screen view once view did appear happens.
    public init(trackingEnabled: Bool = true,
                trackViewsAutomatically: Bool = true) {
        super.init()
        if (trackViewsAutomatically) {
            MBAutomationViewTracking.swizzleViewControllerDidAppear()
        }
        self.trackingEnabled = trackingEnabled
        MBAutomationDatabase.setupTables()
        MBAutomationMessagesManager.startMessagesTimer(time: 30.0)
    }
    
    /// Sets the current view controller, this can be used if automatic view tracking is disabled or to force a particular screen
    public static func trackScreenView(_ viewController: UIViewController) {
        MBAutomationViewTracking.trackViewForViewController(viewController: viewController)
    }
    
    public static func sendEvent(_ event: String,
                                 name: String? = nil,
                                 metadata: [String: Any]? = nil) {
        let event = MBAutomationEvent(event: event,
                                      name: name,
                                      metadata: metadata)
        MBAutomationMessagesManager.eventHappened(event: event)
        MBAutomationTrackingManager.shared.trackEvent(event)
    }
    
    public var applicationStartupOrder: Int {
        return 3
    }
    
    public func applicationStartupBlock() -> ApplicationStartupBlock? {
        return { _, completionBlock in
            MBAutomationTrackingManager.shared.startTimer()
            if let completionBlock = completionBlock {
                completionBlock()
            }
        }
    }
    
    public func messagesReceived(messages: inout [AnyObject], fromStartup: Bool) {
        MBAutomationMessagesManager.setTriggers(toMessages: &messages)
        
        guard let messages = messages as? [MBMessage] else {
            return
        }

        let automationMessages = messages.filter({ $0.automationIsOn })

        //TODO save messages and check triggers
        MBAutomationMessagesManager.saveMessages(automationMessages, fromFetch: true)
        MBAutomationMessagesManager.checkMessages(fromStartup: fromStartup)
    }
}
