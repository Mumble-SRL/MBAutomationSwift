//
//  MBViewTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

/// A view trigger, becomes true when the user opens a view n times
public class MBViewTrigger: MBTrigger {
    /// The view that needs to be opened
    public let view: String
    
    /// The times the user needs to open the view
    public let times: Int
    
    /// Sections the user needs to stay in the view
    public let secondsOnView: TimeInterval
    
    /// The date this trigger becomes true
    public var completionDate: Date?
    
    /// The number of times this event has happened
    public var numberOfTimes: Int?

    /// Initializes a `MBViewTrigger` with the parameters passed
    /// - Parameters:
    ///  - id: The id of the trigger
    ///  - view: The view that needs to be opened
    ///  - times: The times the user needs to open the view
    ///  - secondsOnView: Sections the user needs to stay in the view
    init(id: String,
         view: String,
         times: Int,
         secondsOnView: TimeInterval) {
        self.view = view
        self.times = times
        self.secondsOnView = secondsOnView
        super.init(id: id, type: .view)
    }

    /// Initializes a `MBViewTrigger` with the dictionary returned by the api
    /// - Parameters:
    ///   - dictionary: the dictionary returned by the api
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

    /// Function called when a view is opened
    /// - Returns: If the trigger has changed
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
    
    /// If the trigger is valid
    /// - Parameters:
    ///   - fromAppStartup: if this function is called from startup
    /// - Returns: If this trigger is valid
    override func isValid(fromAppStartup: Bool) -> Bool {
        guard let completionDate = completionDate else {
            return false
        }
        return completionDate >= Date()
    }
    
    // MARK: - Save & retrieve

    /// Initializes a `MBViewTrigger` with the dictionary saved previously
    /// - Parameters:
    ///  - dictionary: The dictionary saved
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

    /// Converts this trigger to a JSON dictionary to be saved
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
