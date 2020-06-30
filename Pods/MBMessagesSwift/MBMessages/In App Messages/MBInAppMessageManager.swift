//
//  MBInAppMessageManager.swift
//  MBInAppMessage
//
//  Created by Lorenzo Oliveto on 17/03/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import SafariServices

internal class MBInAppMessageManager: NSObject {
    static func presentMessages(_ messages: [MBInAppMessage],
                                delegate: MBInAppMessageViewDelegate? = nil,
                                styleDelegate: MBInAppMessageViewStyleDelegate? = nil,
                                ignoreShowedMessages: Bool = false) {
        var messagesToShow = messages
        if !ignoreShowedMessages {
            messagesToShow = messages.filter({ !messageHasBeenShowed(messageId: $0.id) })
        }
        guard messagesToShow.count != 0 else {
            return
        }
        guard let topMostViewController = topMostViewController() else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.presentMessages(messagesToShow,
                                     delegate: delegate,
                                     styleDelegate: styleDelegate)
            }
            return
        }
        presentMessage(atIndex: 0,
                       messages: messagesToShow,
                       delegate: delegate,
                       styleDelegate: styleDelegate,
                       overViewController: topMostViewController)
    }

    private static func presentMessage(atIndex index: Int,
                                       messages: [MBInAppMessage],
                                       delegate: MBInAppMessageViewDelegate? = nil,
                                       styleDelegate: MBInAppMessageViewStyleDelegate? = nil,
                                       overViewController viewController: UIViewController?) {
        guard index < messages.count else {
            return
        }
        let message = messages[index]
        var messageView: MBInAppMessageView?
        if message.style == .bannerTop {
            messageView = MBInAppMessageTopBannerView(message: message,
                                                      delegate: delegate,
                                                      styleDelegate: styleDelegate,
                                                      viewController: viewController)
        } else if message.style == .bannerBottom {
            messageView = MBInAppMessageBottomBannerView(message: message,
                                                         delegate: delegate,
                                                         styleDelegate: styleDelegate,
                                                         viewController: viewController)
        } else if message.style == .center {
            messageView = MBInAppMessageCenterView(message: message,
                                                   delegate: delegate,
                                                   styleDelegate: styleDelegate,
                                                   viewController: viewController)
        } else if message.style == .fullscreenImage {
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
            }
            setMessageShowed(messageId: message.id)
            MBMessageMetrics.createMessageMetricForMessage(metric: .view, messageId: message.id)
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
    
    private static func messageHasBeenShowed(messageId: Int) -> Bool {
        let userDefaults = UserDefaults.standard
        let showedMessages = userDefaults.object(forKey: showedMessagesKey) as? [Int] ?? []
        return showedMessages.contains(messageId)
    }
    
    private static func setMessageShowed(messageId: Int) {
        let userDefaults = UserDefaults.standard
        var showedMessages = userDefaults.object(forKey: showedMessagesKey) as? [Int] ?? []
        if !showedMessages.contains(messageId) {
            showedMessages.append(messageId)
            UserDefaults.standard.set(showedMessages, forKey: showedMessagesKey)
        }
    }
    
    private static var showedMessagesKey: String {
        return "com.mumble.mburger.messages.showedMessages"
    }
}
