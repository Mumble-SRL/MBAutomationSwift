//
//  MBAutomationPushNotificationsManager.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 20/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBMessagesSwift
import UserNotifications

class MBAutomationPushNotificationsManager: NSObject {
    static func showPushNotifications(messages: [MBMessage]) {
        var messagesToShow = messages.filter({ $0.type == .push })
        messagesToShow = messages.filter({ needsToShowMessage(message: $0 ) })
        guard messagesToShow.count != 0 else {
            return
        }
        for message in messages {
            showPushNotification(message: message)
        }
    }

    static internal func cancelPushNotification(forMessage message: MBMessage) {
        let identifier = self.notificationIdentifier(forMessage: message)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        unsetMessageShowed(message: message)
    }
    
    private static func showPushNotification(message: MBMessage) {
        guard let push = message.push else {
            return
        }
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }
            
            var needsToDownloadMedia = false
            let content = UNMutableNotificationContent()
            
            content.title = push.title
            content.body = push.body
            content.badge = NSNumber(value: push.badge ?? 1)
            if let launchImage = push.launchImage {
                content.launchImageName = launchImage
            }
            if let sound = push.sound {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
            } else {
                content.sound = UNNotificationSound.default
            }
            if let userInfo = push.userInfo {
                content.userInfo = userInfo
                if let mediaUrl = userInfo["media_url"] as? String,
                    let fileUrl = URL(string: mediaUrl) {
                    needsToDownloadMedia = true
                    let type = userInfo["media_type"] as? String
                    self.downloadMedia(fileUrl: fileUrl, type: type, content: content, completion: {
                        self.sendPush(id: notificationIdentifier(forMessage: message),
                                      message: message,
                                      content: content)
                    })
                }
            }
            if !needsToDownloadMedia {
                sendPush(id: notificationIdentifier(forMessage: message),
                         message: message,
                         content: content)
            }
        }
    }
    
    private static func sendPush(id: String,
                                 message: MBMessage,
                                 content: UNNotificationContent) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { requests in
            let existingRequest = requests.first(where: { $0.identifier == id })
            guard existingRequest == nil else { // If I have already a request don't schedule another
                return
            }
            
            var trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,
                                                            repeats: false)
            if message.sendAfterDays != 0 {
                let calendar = Calendar.current
                if let date = calendar.date(byAdding: .day, value: message.sendAfterDays, to: Date()) {
                    trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
                }
            }
            let request = UNNotificationRequest(identifier: id,
                                                content: content,
                                                trigger: trigger)

            notificationCenter.add(request) { (error) in
                self.setMessageShowed(message: message)
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
    }
    
    private static func notificationIdentifier(forMessage message: MBMessage) -> String {
        return "mburger.automation.push." + String(message.id)
    }
    
    // MARK: - Saved messages
    
    private static func needsToShowMessage(message: MBMessage) -> Bool {
        if let endDate = message.endDate {
            guard endDate >= Date() else {
                return false
            }
        }
        
        guard let messageId = message.inAppMessage?.id else {
            return false
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
    
    private static func unsetMessageShowed(message: MBMessage) {
        guard let messageId = message.inAppMessage?.id else {
            return
        }
        var showedMessagesCount: [Int: Int] = [:]
        let userDefaults = UserDefaults.standard
        if let outData = userDefaults.data(forKey: showedMessagesCountKey) {
            showedMessagesCount = NSKeyedUnarchiver.unarchiveObject(with: outData) as? [Int: Int] ?? [:]
        }
        let messageShowCount = showedMessagesCount[messageId] ?? 0
        showedMessagesCount[messageId] = max(messageShowCount - 1, 0)
        let data = NSKeyedArchiver.archivedData(withRootObject: showedMessagesCount)
        UserDefaults.standard.set(data, forKey: showedMessagesCountKey)
    }

    private static var showedMessagesCountKey: String {
        return "com.mumble.mburger.automation.pushMessages.showedMessages.count"
    }

    // MARK: - File download
    
    private static func downloadMedia(fileUrl: URL,
                                      type: String?,
                                      content: UNMutableNotificationContent, completion: @escaping () -> Void) {
        let task = URLSession.shared.downloadTask(with: fileUrl) { (location, _, _) in
            if let location = location {
                let tmpDirectory = NSTemporaryDirectory()
                let tmpFile = "file://".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
                let tmpUrl = URL(string: tmpFile)!
                do {
                    try FileManager.default.moveItem(at: location, to: tmpUrl)
                    
                    var options: [String: String]?
                    if let type = type {
                        options = [String: String]()
                        options?[UNNotificationAttachmentOptionsTypeHintKey] = type
                    }
                    if let attachment = try? UNNotificationAttachment(identifier: "media." + fileUrl.pathExtension, url: tmpUrl, options: options) {
                        content.attachments = [attachment]
                    }
                    completion()
                } catch {
                    completion()
                }
            }
        }
        task.resume()
    }

}
