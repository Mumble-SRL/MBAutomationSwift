//
//  MBInAppMessageManager.swift
//  MBInAppMessage
//
//  Created by Lorenzo Oliveto on 17/03/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import SafariServices

/// Main class that manages the displaying of in-app messages, and keeps references of what messages have already been displayed
public class MBInAppMessageManager: NSObject {
    
    /// If the manager is showing messages, this var has the messages showed.
    private static var showingMessages: [MBMessage]? = nil
    
    /// Present an array of in-app messages, if they're not been already presented
    /// - Parameters:
    ///   - messages: The messages that needs to be presented
    ///   - delegate: The `MBInAppMessageViewDelegate` that will receive callbacks when messages are showed/hidden
    ///   - styleDelegate: The style delegate
    ///   - ignoreShowedMessages: if this is true a message will be displayed even if it has already been displayed
    public static func presentMessages(_ messages: [MBMessage],
                                       delegate: MBInAppMessageViewDelegate? = nil,
                                       styleDelegate: MBInAppMessageViewStyleDelegate? = nil,
                                       ignoreShowedMessages: Bool = false) {
        guard showingMessages == nil else {
            let showingMessagesIds: [Int] = (showingMessages ?? []).map({ $0.id })
            var messagesWithoutShowedMessages = messages
            messagesWithoutShowedMessages.removeAll(where: {showingMessagesIds.contains($0.id)})
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.presentMessages(messagesWithoutShowedMessages,
                                     delegate: delegate,
                                     styleDelegate: styleDelegate,
                                     ignoreShowedMessages: ignoreShowedMessages)
            }
            return
        }
        var messagesToShow = messages.filter({ $0.type == .inAppMessage })
        if !ignoreShowedMessages {
            messagesToShow = messages.filter({ needsToShowMessage(message: $0 ) })
        }
        guard messagesToShow.count != 0 else {
            return
        }
        messagesToShow.sort { (m1, m2) -> Bool in
            m1.createdAt.compare(m2.createdAt) == .orderedDescending
        }
        guard let topMostViewController = topMostViewController() else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.presentMessages(messagesToShow,
                                     delegate: delegate,
                                     styleDelegate: styleDelegate)
            }
            return
        }
        showingMessages = messagesToShow
        presentMessage(atIndex: 0,
                       messages: messagesToShow,
                       delegate: delegate,
                       styleDelegate: styleDelegate,
                       overViewController: topMostViewController)
    }

    private static func presentMessage(atIndex index: Int,
                                       messages: [MBMessage],
                                       delegate: MBInAppMessageViewDelegate? = nil,
                                       styleDelegate: MBInAppMessageViewStyleDelegate? = nil,
                                       overViewController viewController: UIViewController?) {
        guard index < messages.count else {
            showingMessages = nil
            return
        }
        let message = messages[index]
        guard let inAppMessage = message.inAppMessage else {
            showingMessages = nil
            return
        }
        var messageView: MBInAppMessageView?
        if inAppMessage.style == .bannerTop {
            messageView = MBInAppMessageTopBannerView(message: message,
                                                      delegate: delegate,
                                                      styleDelegate: styleDelegate,
                                                      viewController: viewController)
        } else if inAppMessage.style == .bannerBottom {
            messageView = MBInAppMessageBottomBannerView(message: message,
                                                         delegate: delegate,
                                                         styleDelegate: styleDelegate,
                                                         viewController: viewController)
        } else if inAppMessage.style == .center {
            messageView = MBInAppMessageCenterView(message: message,
                                                   delegate: delegate,
                                                   styleDelegate: styleDelegate,
                                                   viewController: viewController)
        } else if inAppMessage.style == .fullscreenImage {
            messageView = MBInAppMessageFullscreenImageView(message: message,
                                                            delegate: delegate,
                                                            styleDelegate: styleDelegate,
                                                            viewController: viewController)
        }
        if let messageView = messageView {
            if index + 1 < messages.count {
                messageView.completionBlock = {
                    MBInAppMessageManager.presentMessage(atIndex: index + 1,
                                                         messages: messages,
                                                         delegate: delegate,
                                                         styleDelegate: styleDelegate,
                                                         overViewController: topMostViewController())
                }
            } else {
                messageView.completionBlock = {
                    showingMessages = nil
                }
            }
            messageView.buttonPressedBlock = {
                showingMessages = nil
            }
            setMessageShowed(message: message)
            MBMessageMetrics.createMessageMetricForInAppMessage(metric: .view, messageId: message.id)
            messageView.present()
        }
    }
    
    private static func topMostViewController(_ controller: UIViewController? = nil) -> UIViewController? {
        var controller = controller
        if controller == nil {
            if #available(iOS 13.0, *) {
            controller = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
            } else {
                controller = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        if let navigationController = controller as? UINavigationController {
            return topMostViewController(navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topMostViewController(selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topMostViewController(presented)
        }
        return controller
    }
    
    // MARK: - Showed message handling
    
    private static func needsToShowMessage(message: MBMessage) -> Bool {
        if message.automationIsOn {
            guard message.endDate >= Date() else {
                return false
            }
        }
        guard let messageId = message.inAppMessage?.id else {
            return false
        }
        if message.inAppMessage?.isBlocking ?? false {
            return true
        }
        var showedMessagesCount: [Int: Int] = [:]
        let userDefaults = UserDefaults.standard
        if let outData = userDefaults.data(forKey: showedMessagesCountKey) {
            showedMessagesCount = NSKeyedUnarchiver.unarchiveObject(with: outData) as? [Int: Int] ?? [:]
        }
        let messageShowCount = showedMessagesCount[messageId] ?? 0
        return messageShowCount <= message.repeatTimes
    }
    
    private static func setMessageShowed(message: MBMessage) {
        guard let messageId = message.inAppMessage?.id else {
            return
        }
        var showedMessagesCount: [Int: Int] = [:]
        let userDefaults = UserDefaults.standard
        if let outData = userDefaults.data(forKey: showedMessagesCountKey) {
            showedMessagesCount = NSKeyedUnarchiver.unarchiveObject(with: outData) as? [Int: Int] ?? [:]
        }
        let messageShowCount = showedMessagesCount[messageId] ?? 0
        showedMessagesCount[messageId] = messageShowCount + 1
        let data = NSKeyedArchiver.archivedData(withRootObject: showedMessagesCount)
        UserDefaults.standard.set(data, forKey: showedMessagesCountKey)
    }
    
    private static var showedMessagesCountKey: String {
        return "com.mumble.mburger.messages.showedMessages.count"
    }
}
