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

/// The automation plugin
public class MBAutomation: NSObject, MBPlugin {
    
    /// If tracking is enabled for this plugin, if this is false all events and views will not be saved and sent to the server
    var trackingEnabled: Bool = true
    
    /// The frequency used to send events and view to MBurger
    var eventsTimerTime: TimeInterval = 10 {
        didSet {
            MBAutomationTrackingManager.shared.timerTime = eventsTimerTime
        }
    }
    
    /// Initializes the plugin, if trackViewsAutomatically if yes the views are tracked automatically. It uses method swizzling to track automatically screen view once view did appear happens.
    /// - Parameters:
    ///   - trackingEnabled: If the tracking is enabled, default to `true`
    ///   - trackViewsAutomatically: If automatic tracking of view is enabled or not, default to `true`
    ///   - eventsTimerTime: The frequency used to send events and view to MBurger
    public init(trackingEnabled: Bool = true,
                trackViewsAutomatically: Bool = true,
                eventsTimerTime: TimeInterval = 10.0) {
        super.init()
        if trackViewsAutomatically {
            MBAutomationViewTracking.swizzleViewControllerDidAppear()
        }
        self.trackingEnabled = trackingEnabled
        MBAutomationDatabase.setupTables()
        MBAutomationMessagesManager.startMessagesTimer(time: 30.0)
        MBAutomationTrackingManager.shared.timerTime = eventsTimerTime
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    /// Sets the current view controller, this can be used if automatic view tracking is disabled or to force a particular screen
    public static func trackScreenView(_ viewController: UIViewController) {
        MBAutomationViewTracking.trackViewForViewController(viewController: viewController)
    }
    
    /// Send and event with automation
    /// - Parameters:
    ///   - event: The event.
    ///   - name: The name of the event that will be displayed on MBurger dashboard, default `nil`
    ///   - metadata: Additional metadata sent with the event
    public static func sendEvent(_ event: String,
                                 name: String? = nil,
                                 metadata: [String: Any]? = nil) {
        let event = MBAutomationEvent(event: event,
                                      name: name,
                                      metadata: metadata)
        MBAutomationMessagesManager.eventHappened(event: event)
        MBAutomationTrackingManager.shared.trackEvent(event)
    }
    
    /// Startup order for the plugin block
    public var applicationStartupOrder: Int {
        return 3
    }
    
    /// Block executed at startup
    public func applicationStartupBlock() -> MBApplicationStartupBlock? {
        return { _, completionBlock in
            MBAutomationTrackingManager.shared.startTimer()
            if let completionBlock = completionBlock {
                completionBlock()
            }
        }
    }
    
    /// Invoked by the MBurger plugins manager when a new message is received by the `MBMessages` plugin
    /// - Parameters:
    ///   - messages: The messages received, the triggers property will be populated with a `MBTrigger` object.
    ///   - fromStartup: if messages has been retrieved at app startup
    public func messagesReceived(messages: inout [AnyObject], fromStartup: Bool) {
        MBAutomationMessagesManager.setTriggers(toMessages: &messages)
        
        guard let messages = messages as? [MBMessage] else {
            return
        }

        let automationMessages = messages.filter({ $0.automationIsOn })

        MBAutomationMessagesManager.saveMessages(automationMessages, fromFetch: true)
        MBAutomationMessagesManager.checkMessages(fromStartup: fromStartup)
    }
    
    /// Invoked by the MBurger plugins manager when a tag changes in the `MBAudience` plugin
    /// - Parameters:
    ///   - tag: The tag.
    ///   - value: The value of the tag, nil if the tag has been deleted.
    public func tagChanged(tag: String, value: String?) {
        MBAutomationMessagesManager.tagChanged(tag: tag, value: value)
    }

    /// Invoked by the MBurger plugins manager when new location data is available in the `MBAudience` plugin
    /// - Parameters:
    ///   - latitude: The new latitude.
    ///   - longitude: The new longitude.
    public func locationDataUpdated(latitude: Double, longitude: Double) {
        MBAutomationMessagesManager.locationDataUpdated(latitude: latitude, longitude: longitude)
    }

    @objc private func applicationDidBecomeActive() {
        MBAutomationMessagesManager.checkMessages(fromStartup: false)
    }
}
