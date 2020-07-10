//
//  MBInAppMessage.swift
//  MBInAppMessage
//
//  Created by Lorenzo Oliveto on 20/04/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBurgerSwift
import MBNetworkingSwift

/// The delegate of the plugin, you can use this to check if the message check fails.
public protocol MBMessagesDelegate: class {
    /// Tells the delegate the the message check failed
    /// - Parameters:
    ///   - sender: The `MBMessages` plugins that sent checked the messages.
    ///   - error: An optional error with the motivation oof the fail
    func campaignsCheckFailed(sender: MBMessages, error: Error?)
}

/// This is the main entry point to manage all the messages features of MBurger.
/// To use create an instance of MBMessages and add it to the MBManager plugins.
/// `MBManager.shared.plugins = [MBMessages()]`
/// You can pass other options described below in the init method described below.
/// You will also need to add this line if you want to start the messages fetch at startup:
/// `MBManager.shared.applicationDidFinishLaunchingWithOptions(launchOptions: launchOptions)`
public class MBMessages: NSObject, MBPlugin {
    
    /// The delegate of the plugin, you can use this to check if the message check fails.
    public weak var delegate: MBMessagesDelegate?
    
    /// The view delegate of the plugin, you can use this to have callbacks when messages
    /// are showed or hidden. You will need to use this if the app needs to intercept
    /// the pressing of the buttons.
    public weak var viewDelegate: MBInAppMessageViewDelegate?
    
    /// The style delegate of the plugin, you can use tthis to customize colors and fonts of
    /// `MBMessageView` instances. Settings a custom color with this delegate will override the one inserted in the dashboard.
    public weak var styleDelegate: MBInAppMessageViewStyleDelegate?
    
    /// The delayed used to delay the presenting of the message after a successful fetch.
    /// The default is 1 second.
    public var messagesDelay: TimeInterval = 1
    
    /// Settings this var to true will always display the messages returned by the api, even if they've been already showed.
    public var debug = false
    
    /// This method initialises the messages plugin with the parameters passed
    /// - Parameters:
    ///   - delegate: The `MBMessagesDelegate` of the plugin. Use this to receive a callback when the manager encounters an error retrieving the messages from the server
    ///   - viewDelegate: The `MBInAppMessageViewDelegate` of the plugin. Use this to receive callbacks when `MBMessageView` instances are showed or when a button is pressed
    ///   - styleDelegate: The `MBInAppMessageViewStyleDelegate` of the plugin. Use this to customize colors and fonts of `MBMessageView` instances.
    ///   - messagesDelay: The delay applied before a `MBMessageView` is showed. Defaults to 1 second
    ///   - debug: If this is true the plugin will show all the messages, even if they've already been shoowed
    public init(delegate: MBMessagesDelegate? = nil,
                viewDelegate: MBInAppMessageViewDelegate? = nil,
                styleDelegate: MBInAppMessageViewStyleDelegate? = nil,
                messagesDelay: TimeInterval = 1,
                debug: Bool = false) {
        super.init()
        self.delegate = delegate
        self.viewDelegate = viewDelegate
        self.styleDelegate = styleDelegate
        self.messagesDelay = messagesDelay
        self.debug = debug
        checkCampaigns()
        NotificationCenter.default.addObserver(self, selector: #selector(checkCampaigns), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    /// This method checks the campaigns from the server and shows them, if needed.
    /// It's called automatically at startup, but it can be called to force the check.
    /// If the check fails it wil call the `inAppMessageCheckFailed` of the `delegate`
    @objc public func checkCampaigns() {
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "campaigns",
                             method: .get,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { [weak self] response in
                                guard let body = response["body"] as? [[String: Any]] else {
                                    return
                                }
                                
                                guard body.count != 0 else {
                                    return
                                }
                                
                                let campaigns = body.map({ MBCampaign(dictionary: $0)})
                                MBPluginsManager.campaignsReceived(campaigns: campaigns)
                                
                                let delay = self?.messagesDelay ?? 0
                                let messagesCampaigns = campaigns.filter({ $0.type == .inAppMessage })
                                
                                let messages = messagesCampaigns.compactMap({ $0.message })
                                
                                guard messages.count != 0 else {
                                    return
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                                    MBInAppMessageManager.presentMessages(messages,
                                                                          delegate: self?.viewDelegate,
                                                                          styleDelegate: self?.styleDelegate,
                                                                          ignoreShowedMessages: self?.debug ?? false)
                                })
            }, failure: { error in
                self.delegate?.campaignsCheckFailed(sender: self, error: error)
        })
    }
    
    // MARK: - Push handling
    
    /// The `pushToken` of the push notifications plugin of MBurger.
    /// This will set the token of the MPushSwift SDK.
    /// If you need help setting up the push notifiications go to the [MPush documentation](https://docs.mumbleideas.it/mpush/ios/introduction/).
    public static var pushToken: String {
        set {
            MBPush.pushToken = newValue
        }
        get {
            return MBPush.pushToken
        }
    }
    
    /// A block that will be called when the user interacts with a push notification, it can be used as an unique point to take actions when the user interacts with a notification.
    /// - Parameters:
    ///   - notificationDictionary: The `userInfo` dictionary arrived with the notification
    public static var userDidInteractWithNotificationBlock: ((_ notificationDictionary: [String: AnyHashable]) -> Void)?
    
    /// Register a device token to receive push notifications.
    /// This will call the device registration of the MPushSwift SDK.
    /// - Parameters:
    ///   - deviceToken: The device token data returned in didRegisterForRemoteNotificationsWithDeviceToken
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    public static func registerDeviceToPush(deviceToken: Data,
                                            success: (() -> Void)? = nil,
                                            failure: ((_ error: Error?) -> Void)? = nil) {
        MBPush.registerDevice(deviceToken: deviceToken, success: success, failure: failure)
    }
    
    /// Register the current device to a push topic.
    /// This will call the topic registration of the MPushSwift SDK.
    ///
    /// - Parameters:
    ///   - topic: The topic you will register to
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    public static func registerPushMessages(toTopic topic: String,
                                            success: (() -> Void)? = nil,
                                            failure: ((_ error: Error?) -> Void)? = nil) {
        MBPush.register(toTopic: topic, success: success, failure: failure)
    }
    
    /// Register the current device to an array of push topics.
    /// This will call the topics registration of the MPushSwift SDK.
    ///
    /// - Parameters:
    ///   - topics: The topics you will register to
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    public static func registerPushMessages(toTopics topics: [String],
                                            success: (() -> Void)? = nil,
                                            failure: ((_ error: Error?) -> Void)? = nil) {
        MBPush.register(toTopics: topics, success: success, failure: failure)
    }
    
    /// Unregister the current device from a push topic.
    /// This will call the topic unregister of the MPushSwift SDK.
    ///
    /// - Parameters:
    ///   - topic: The topic you will unregister from
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    public static func unregisterPushMessages(fromTopic topic: String,
                                              success: (() -> Void)? = nil,
                                              failure: ((_ error: Error?) -> Void)? = nil) {
        MBPush.unregister(fromTopic: topic, success: success, failure: failure)
    }
    
    /// Unregister the current device from an array of topics.
    /// This will call the topics unregister of the MPushSwift SDK.
    ///
    /// - Parameters:
    ///   - topics: The topics you will unregister from
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    public static func unregisterPushMessages(fromTopics topics: [String],
                                              success: (() -> Void)? = nil,
                                              failure: ((_ error: Error?) -> Void)? = nil) {
        MBPush.unregister(fromTopics: topics, success: success, failure: failure)
    }
    
    /// Unregister the current device from all topics is registred to.
    /// This will call the function to unregister all topics of the MPushSwift SDK.
    ///
    /// - Parameters:
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    public static func unregisterPushMessagesFromAllTopics(success: (() -> Void)? = nil,
                                                           failure: ((_ error: Error?) -> Void)? = nil) {
        MBPush.unregisterFromAllTopics(success: success, failure: failure)
    }
    
    // MARK: - Metrics and notifications callbacks
    
    /**
     This function and `userNotificationCenter(didReceive response...` is used by the `MBMessages` SDK to have informations when a push arrives and the user interacts with it.
     You need to call this function from the app (when it receives it as a `UNUserNotificationCenter` delegate) in order to see metrics of push notifications in the dashboard and to have the `userDidInteractWithNotificationBlock` called.
     Example usage:
     
     func userNotificationCenter(_ center: UNUserNotificationCenter,
     willPresent notification: UNNotification,
     withCompletionHandler
     completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
     MBMessages.userNotificationCenter(willPresent: notification)
     completionHandler(UNNotificationPresentationOptions.alert)
     }
     
     - Parameters:
     - notification: The notification passed by the `UserNotifications` framework to the delegate.
     */
    public static func userNotificationCenter(willPresent notification: UNNotification) {
        MBMessageMetrics.userNotificationCenter(willPresent: notification)
    }
    
    /**
     This function and `userNotificationCenter(willPresent notification...` is used by the `MBMessages` SDK to have informations when a push arrives and the user interacts with it.
     You need to call this function from the app (when it receives it as a `UNUserNotificationCenter` delegate) in order to see metrics of push notifications in the dashboard and to have the `userDidInteractWithNotificationBlock` called.
     Example usage:
     
     func userNotificationCenter(_ center: UNUserNotificationCenter,
     didReceive response: UNNotificationResponse,
     withCompletionHandler
     completionHandler: @escaping () -> Void) {
     MBMessages.userNotificationCenter(didReceive: response)
     completionHandler()
     }
     
     - Parameters:
     - response: The response passed by the `UserNotifications` framework to the delegate.
     **/
    public static func userNotificationCenter(didReceive response: UNNotificationResponse) {
        MBMessageMetrics.userNotificationCenter(didReceive: response, userDidInteractWithNotificationBlock: userDidInteractWithNotificationBlock)
    }
    
    // MARK: - Plugin startup
    
    /// The order in wich MBurger will call the startup blocks.
    /// This function is used by the main MBurger SDK and should not be called.
    /// - Returns: the order as an int.
    public var applicationStartupOrder: Int {
        return 2
    }
    
    /// The startup blocks called by the main MBurger SDK.
    /// This function is used by the main MBurger SDK and should not be called.
    /// - Returns: a block that is executed at startup.
    public func applicationStartupBlock() -> ApplicationStartupBlock? {
        let block: ApplicationStartupBlock = { launchOptions, completionBlock in
            MBMessageMetrics.applicationDidFinishLaunchingWithOptions(launchOptions: launchOptions, userDidInteractWithNotificationBlock: MBMessages.userDidInteractWithNotificationBlock, completionBlock: {
                if let completionBlock = completionBlock {
                    completionBlock()
                }
            })
        }
        return block
    }
}
