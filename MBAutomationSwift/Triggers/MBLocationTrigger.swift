//
//  MBLocationTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import CoreLocation

/// The trigger action that needs to happen
public enum LocationTriggerAction: Int {
    /// The user enters the region
    case enter
    
    /// The user exits the region
    case exit
    
    /// Converts the string coming from the api to a `LocationTriggerAction`, defaults to `.exit` if no match is found
    /// - Parameters:
    ///   - actionString: The string that is converted
    /// - Returns: The location trigger action.
    static func tirgger(forActionString actionString: String) -> LocationTriggerAction {
        if actionString == "enter" {
            return .enter
        } else if actionString == "exit" {
            return .exit
        }
        return .enter
    }
}

/// A location trigger, fires if the user enters/exits a region
public class MBLocationTrigger: MBTrigger {
    
    /// The address of the trigger
    public let address: String
    /// The latitude of the trigger
    public let latitude: Float
    /// The longitude of the trigger
    public let longitude: Float
    
    /// The radius of the region in meters
    public let radius: Float
    
    /// A delay for this trigger
    public let after: TimeInterval
    
    /// If the user needs to enter/exit the region in order for this trigger to become valid
    public let action: LocationTriggerAction

    /// The date this trigger becomes true
    var completionDate: Date?
    
    /// Initializes a `MBLocationTrigger` with the parameters passed
    /// - Parameters:
    ///  - id: The id of the trigger
    ///  - address:  The address of the trigger
    ///  - latitude: Latitude for this trigger
    ///  - longitude: Longitude for this trigger
    ///  - radius: The radius of the region that will be checked
    ///  - after: An optional delay for this trigger
    ///  - action: If the user needs to enter/exit the region in order for this trigger to become valid
    init(id: String,
         address: String,
         latitude: Float,
         longitude: Float,
         radius: Float,
         after: TimeInterval,
         action: LocationTriggerAction) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.after = after
        self.action = action
        super.init(id: id, type: .location)
    }
    
    /// Initializes a `MBLocationTrigger` with the dictionary returned by the api
    /// - Parameters:
    ///   - dictionary: the dictionary returned by the api
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let address = dictionary["address"] as? String ?? ""
        let latitudeNumber = dictionary["latitude"] as? NSNumber
        let longitudeNumber = dictionary["longitude"] as? NSNumber
        let radius = dictionary["radius"] as? Float ?? 0
        let after = dictionary["after"] as? TimeInterval ?? 0

        let actionString = dictionary["action"] as? String ?? "enter"
        let action = LocationTriggerAction.tirgger(forActionString: actionString)
        
        self.init(id: id,
                  address: address,
                  latitude: latitudeNumber?.floatValue ?? 0,
                  longitude: longitudeNumber?.floatValue ?? 0,
                  radius: radius,
                  after: after,
                  action: action)
    }
    
    /// Function called when new location is available in MBAudience
    /// - Parameters:
    ///   - location: the new location
    ///   - lastLocation: the last location saved
    /// - Returns: Returns `true` if the trigger has changed
    func locationDataUpdated(location: CLLocationCoordinate2D,
                             lastLocation: CLLocationCoordinate2D?) -> Bool {
        guard completionDate == nil else {
            return false
        }
        
        let triggerRegion = self.region()
        let isInside = triggerRegion.contains(location)
        
        var locationTriggerSatisfied = false
        if let lastLocation = lastLocation {
            if action == .enter && isInside {
                let lastLocationIsInside = triggerRegion.contains(lastLocation)
                locationTriggerSatisfied = lastLocationIsInside
            } else if action == .exit && !isInside {
                let lastLocationIsInside = triggerRegion.contains(lastLocation)
                locationTriggerSatisfied = !lastLocationIsInside
            }
        } else {
            if action == .enter && isInside {
                locationTriggerSatisfied = true
            }
        }
        if locationTriggerSatisfied {
            if after == 0 {
                completionDate = Date()
                return true
            } else {
                completionDate = Date().addingTimeInterval(after)
                return false
            }
        }
        return false
    }
    
    /// The region for this trigger, with center (`latitude`, `longitude`) and `radius`
    /// - Returns: The region for this trigger
    func region() -> CLCircularRegion {
        let regionIdentifier = "com.mumble.mburger.automation.trigger.region" + String(self.id)
        let lat = CLLocationDegrees(latitude)
        let lng = CLLocationDegrees(latitude)
        let radius = CLLocationDistance(self.radius)
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lng), radius: radius, identifier: regionIdentifier)
        return region
    }
    
    /// If the trigger is valid
    /// - Parameters:
    ///   - fromAppStartup: if this function is called from startup
    /// - Returns: If this trigger is valid
    override func isValid(fromAppStartup: Bool) -> Bool {
        return completionDate == nil
    }
    
    // MARK: - Save & retrieve

    /// Initializes a `MBLocationTrigger` with the dictionary saved previously
    /// - Parameters:
    ///  - dictionary: The dictionary saved
    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let address = dictionary["address"] as? String ?? ""
        let latitude = dictionary["latitude"] as? Float ?? 0
        let longitude = dictionary["longitude"] as? Float ?? 0
        let radius = dictionary["radius"] as? Float ?? 0
        let after = dictionary["after"] as? TimeInterval ?? 0
        let actionInt = dictionary["action"] as? Int ?? 0
        let action = LocationTriggerAction(rawValue: actionInt) ?? .enter
        self.init(id: id,
                  address: address,
                  latitude: latitude,
                  longitude: longitude,
                  radius: radius,
                  after: after,
                  action: action)
        if let completionDate = dictionary["completionDate"] as? TimeInterval {
            self.completionDate = Date(timeIntervalSince1970: completionDate)
        }
    }

    /// Converts this trigger to a JSON dictionary to be saved
    override func toJsonDictionary() -> [String: Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["address"] = address
        dictionary["latitude"] = latitude
        dictionary["longitude"] = longitude
        dictionary["radius"] = radius
        dictionary["after"] = after
        dictionary["action"] = action.rawValue

        if let completionDate = completionDate {
            dictionary["completionDate"] = completionDate.timeIntervalSince1970
        }
        return dictionary
    }

}
