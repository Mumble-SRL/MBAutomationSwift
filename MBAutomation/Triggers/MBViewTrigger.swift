//
//  MBViewTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

public class MBViewTrigger: MBTrigger {
    public let view: String
    
    public let times: Int
    public let secondsOnView: TimeInterval
    
    public var completionDate: Date? // The date this trigger becomes true
    public var numberOfTimes: Int? // The number of times this event happens

    init(id: String,
         view: String,
         times: Int,
         secondsOnView: TimeInterval) {
        self.view = view
        self.times = times
        self.secondsOnView = secondsOnView
        super.init(id: id, type: .view)
    }

    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let view = dictionary["view_name"] as? String ?? ""
        let times = dictionary["times"] as? Int ?? 0
        let secondsOnView = dictionary["seconds_on_view"] as? TimeInterval ?? 0

        self.init(id: id,
                  view: view,
                  times: times,
                  secondsOnView: secondsOnView)
    }

    func screenViewed(view: MBAutomationView) -> Bool {
        if view.view == self.view {
            if let numberOfTimes = numberOfTimes {
                self.numberOfTimes = numberOfTimes + 1
            } else {
                numberOfTimes = 1
            }
            return true
        }
        return false
    }
    
    internal func setCompleted() {
        completionDate = Date()
    }
    
    override func isValid(fromAppStartup: Bool) -> Bool {
        return completionDate != nil
    }
    
    // MARK: - Save & retrieve

    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let view = dictionary["view"] as? String ?? ""
        let times = dictionary["times"] as? Int ?? 0
        let secondsOnView = dictionary["secondsOnView"] as? TimeInterval ?? 0
        self.init(id: id,
                  view: view,
                  times: times,
                  secondsOnView: secondsOnView)
        
        if let completionDate = dictionary["completionDate"] as? TimeInterval {
            self.completionDate = Date(timeIntervalSince1970: completionDate)
        }
        self.numberOfTimes = dictionary["numberOfTimes"] as? Int
    }

    override func toJsonDictionary() -> [String: Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["view"] = view
        dictionary["times"] = times
        dictionary["secondsOnView"] = secondsOnView
        
        if let completionDate = completionDate {
            dictionary["completionDate"] = completionDate.timeIntervalSince1970
        }
        if let numberOfTimes = numberOfTimes {
            dictionary["numberOfTimes"] = numberOfTimes
        }

        return dictionary
    }

}
