//
//  MBMessageMetrics.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 22/04/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBurgerSwift
import MBNetworkingSwift

enum MBMessageMetricsMetricType: String {
    case push
    case inapp
}

enum MBMessageMetricsMetric: String {
    case view
    case interaction
}

class MBMessageMetrics: NSObject {
    static func applicationDidFinishLaunchingWithOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, userDidInteractWithNotificationBlock: (([String: AnyHashable]) -> Void)?, completionBlock: @escaping () -> Void) {
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyHashable] {
            if let userDidInteractWithNotificationBlock = userDidInteractWithNotificationBlock {
                userDidInteractWithNotificationBlock(userInfo)
            }
            checkNotificationPayload(userInfo: userInfo, forMetric: .interaction, completionBlock: completionBlock)
        } else {
            completionBlock()
        }
    }
    
    static func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        if let userInfo = request.content.userInfo as? [String: AnyHashable] {
            checkNotificationPayload(userInfo: userInfo, forMetric: .view, completionBlock: {})
        }
    }
    
    static func userNotificationCenter(willPresent notification: UNNotification) {
        if let userInfo = notification.request.content.userInfo as? [String: AnyHashable] {
            checkNotificationPayload(userInfo: userInfo, forMetric: .view, completionBlock: {})
        }
    }
    
    public static func userNotificationCenter(didReceive response: UNNotificationResponse, userDidInteractWithNotificationBlock: (([String: AnyHashable]) -> Void)?) {
        if let userInfo = response.notification.request.content.userInfo as? [String: AnyHashable] {
            if let userDidInteractWithNotificationBlock = userDidInteractWithNotificationBlock {
                userDidInteractWithNotificationBlock(userInfo)
            }
            checkNotificationPayload(userInfo: userInfo, forMetric: .interaction, completionBlock: {})
        }
    }
    
    internal static func checkNotificationPayload(userInfo: [String: Any],
                                                  forMetric metric: MBMessageMetricsMetric,
                                                  completionBlock: @escaping () -> Void) {
        if let messageId = userInfo["message_id"] as? Int {
            if metric == .interaction && !pushNotificationMetricSent(metric: .view, messageId: messageId) {
                createMessageMetricForPush(metric: .view, messageId: messageId, completionBlock: {
                    createMessageMetricForPush(metric: metric,
                                               messageId: messageId,
                                               completionBlock: completionBlock)
                })
            } else {
                createMessageMetricForPush(metric: metric,
                                           messageId: messageId,
                                           completionBlock: completionBlock)
            }
        } else {
            completionBlock()
        }
    }
    
    internal static func createMessageMetricForPush(metric: MBMessageMetricsMetric,
                                                    messageId: Int,
                                                    completionBlock: @escaping () -> Void) {
        guard !pushNotificationMetricSent(metric: metric, messageId: messageId) else {
            return
        }
        setPushNotificationMetricShowed(metric: metric, messageId: messageId)
        createMessageMetric(metric: metric, messageId: messageId, success: {
            completionBlock()
        }, failure: { _ in
            completionBlock()
        })
    }
    
    internal static func createMessageMetricForInAppMessage(metric: MBMessageMetricsMetric,
                                                            messageId: Int) {
        createMessageMetric(metric: metric, messageId: messageId)
    }
    
    private static func createMessageMetric(metric: MBMessageMetricsMetric,
                                            messageId: Int,
                                            success: (() -> Void)? = nil,
                                            failure: ((_ error: Error) -> Void)? = nil) {
        var parameters = [String: Any]()
        parameters["metric"] = metric.rawValue
        parameters["message_id"] = NSNumber(value: messageId).stringValue
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "metrics",
                             method: .post,
                             parameters: parameters,
                             development: MBManager.shared.development,
                             success: { _ in
                                if let success = success {
                                    success()
                                }
        }, failure: { error in
            if let failure = failure {
                failure(error)
            }
        })
    }
    
    private static func pushNotificationMetricSent(metric: MBMessageMetricsMetric, messageId: Int) -> Bool {
        let userDefaults = UserDefaults.standard
        let viewSentNotificationIds = userDefaults.object(forKey: pushNotificationViewedKey) as? [String] ?? []
        let metricString = self.metricString(metric: metric, messageId: messageId)
        return viewSentNotificationIds.contains(metricString)
    }
    
    private static func setPushNotificationMetricShowed(metric: MBMessageMetricsMetric, messageId: Int) {
        let userDefaults = UserDefaults.standard
        var viewSentNotificationIds = userDefaults.object(forKey: pushNotificationViewedKey) as? [String] ?? []
        let metricString = self.metricString(metric: metric, messageId: messageId)
        if !viewSentNotificationIds.contains(metricString) {
            viewSentNotificationIds.append(metricString)
            UserDefaults.standard.set(viewSentNotificationIds, forKey: pushNotificationViewedKey)
        }
    }
    
    private static func metricString(metric: MBMessageMetricsMetric, messageId: Int) -> String {
        return metric.rawValue + "_" + String(messageId)
    }
    
    private static var pushNotificationViewedKey: String {
        return "com.mumble.mburger.messages.pushNotificationViewed"
    }
}
