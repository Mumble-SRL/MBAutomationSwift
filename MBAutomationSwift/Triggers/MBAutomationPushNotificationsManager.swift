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
        messagesToShow = messages.filter({ !messageHasBeenShowed(message: $0 ) })
        guard messagesToShow.count != 0 else {
            return
        }
        showPushNotifications(messages: messagesToShow)
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
                        self.sendPushNow(id: notificationIdentifier(forMessage: message), content: content)
                    })
                }
            }
            if !needsToDownloadMedia {
                sendPushNow(id: notificationIdentifier(forMessage: message), content: content)
            }
        }
    }
    
    private static func sendPushNow(id: String, content: UNNotificationContent) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: id,
                                            content: content,
                                            trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    private static func notificationIdentifier(forMessage message: MBMessage) -> String {
        return "mburger.automation.push." + String(message.id)
    }
    
    // MARK: - Saved messages
    
    private static func messageHasBeenShowed(message: MBMessage) -> Bool {
        guard let messageId = message.inAppMessage?.id else {
            return false
        }
        let userDefaults = UserDefaults.standard
        let showedMessages = userDefaults.object(forKey: showedMessagesKey) as? [Int] ?? []
        return showedMessages.contains(messageId)
    }
    
    private static func setMessageShowed(message: MBMessage) {
        guard let messageId = message.inAppMessage?.id else {
            return
        }
        let userDefaults = UserDefaults.standard
        var showedMessages = userDefaults.object(forKey: showedMessagesKey) as? [Int] ?? []
        if !showedMessages.contains(messageId) {
            showedMessages.append(messageId)
            UserDefaults.standard.set(showedMessages, forKey: showedMessagesKey)
        }
    }
    
    private static var showedMessagesKey: String {
        return "com.mumble.mburger.automation.pushMessages.showedMessages"
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
