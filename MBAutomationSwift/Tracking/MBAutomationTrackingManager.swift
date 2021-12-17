//
//  MBAutomationTrackingManager.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBurgerSwift

class MBAutomationTrackingManager: NSObject {
    static let shared = MBAutomationTrackingManager()
    
    var timerTime = TimeInterval(10) {
        didSet {
            if checkQueueTimer != nil {
                // The invalidation is done in startTimer()
                startTimer()
            }
        }
    }
    
    var checkQueueTimer: Timer?
    
    var sendingData: Bool = false
    
    func trackView(_ view: MBAutomationView) {
        saveViewInDb(view)
    }
    
    func trackEvent(_ event: MBAutomationEvent) {
        saveEventInDb(event)
    }
    
    // MARK: - DB Save
    
    private func saveViewInDb(_ view: MBAutomationView) {
        guard trackingEnabled() else {
            return
        }
        MBAutomationDatabase.saveView(view)
    }
    
    private func saveEventInDb(_ event: MBAutomationEvent) {
        guard trackingEnabled() else {
            return
        }
        MBAutomationDatabase.saveEvent(event)
    }
    
    private func trackingEnabled() -> Bool {
        guard let plugin = MBManager.shared.plugins.first(where: { $0 is MBAutomation }) as? MBAutomation else {
            return false
        }
        return plugin.trackingEnabled
    }
    
    func startTimer() {
        if let timer = checkQueueTimer {
            timer.invalidate()
            checkQueueTimer = nil
        }
        checkQueueTimer = Timer.scheduledTimer(timeInterval: timerTime, target: self, selector: #selector(checkQueue), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if let timer = checkQueueTimer {
            timer.invalidate()
            checkQueueTimer = nil
        }
    }
    
    @objc func checkQueue() {
        // If already sending data skip this cycle and do the task on next
        if sendingData {
            return
        }
        sendingData = true
        checkViewsQueue { [weak self] in
            if let strongSelf = self {
                strongSelf.checkEventsQueue { [weak self] in
                    if let strongSelf = self {
                        strongSelf.sendingData = false
                    }
                }
            }
        }
    }
    
    private func checkViewsQueue(completion: (() -> Void)? = nil) {
        MBAutomationDatabase.views { views in
            guard let views = views else {
                if let completion = completion {
                    completion()
                }
                return
            }
            guard views.count != 0 else {
                if let completion = completion {
                    completion()
                }
                return
            }
            
            let viewsDictionaries = views.compactMap({ $0.apiDictionary() })
            MBApiManager.request(withToken: MBManager.shared.apiToken,
                                 locale: MBManager.shared.localeString,
                                 apiName: "project/client-views",
                                 method: .post,
                                 parameters: ["views": viewsDictionaries],
                                 development: MBManager.shared.development,
                                 success: { _ in
                                    MBAutomationDatabase.deleteViews(views, completion: {
                                        if let completion = completion {
                                            completion()
                                        }
                                    })
            }, failure: { _ in
                if let completion = completion {
                    completion()
                }
            })
        }
    }
    
    private func checkEventsQueue(completion: (() -> Void)? = nil) {
        MBAutomationDatabase.events { events in
            guard let events = events else {
                if let completion = completion {
                    completion()
                }
                return
            }
            guard events.count != 0 else {
                if let completion = completion {
                    completion()
                }
                return
            }
            
            let eventsDictionaries = events.compactMap({ $0.apiDictionary() })
            MBApiManager.request(withToken: MBManager.shared.apiToken,
                                 locale: MBManager.shared.localeString,
                                 apiName: "project/client-events",
                                 method: .post,
                                 parameters: ["events": eventsDictionaries],
                                 development: MBManager.shared.development,
                                 success: { _ in
                                    MBAutomationDatabase.deleteEvents(events, completion: {
                                        if let completion = completion {
                                            completion()
                                        }
                                    })
            }, failure: { _ in
                if let completion = completion {
                    completion()
                }
            })
        }
    }
}
