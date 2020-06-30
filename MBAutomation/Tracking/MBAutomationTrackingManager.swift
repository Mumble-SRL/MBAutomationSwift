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
    
    let timerTime = TimeInterval(10)
    var checkQueueTimer: Timer?
    
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
        checkViewsQueue { [weak self] in
            if let strongSelf = self {
                strongSelf.checkEventsQueue()
            }
        }
    }
    
    private func checkViewsQueue(completion: (() -> Void)? = nil) {
        MBAutomationDatabase.views { views in
            guard let views = views else  {
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

            print(views)
            
            if let completion = completion {
                completion()
            }
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
            
            print(events)
        }
    }

}
