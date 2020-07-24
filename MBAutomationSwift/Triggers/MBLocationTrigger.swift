//
//  MBLocationTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import CoreLocation

public enum LocationTriggerAction: Int {
    case enter
    case exit
    
    static func tirgger(forActionString actionString: String) -> LocationTriggerAction {
        if actionString == "enter" {
            return .enter
        } else if actionString == "exit" {
            return .exit
        }
        return .enter
    }
}

public class MBLocationTrigger: MBTrigger {
    public let address: String
    public let latitude: Float
    public let longitude: Float
    
    /// Radius in meters
    public let radius: Float
    public let after: TimeInterval
    
    public let action: LocationTriggerAction

    var completionDate: Date?
    
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
    
    func region() -> CLCircularRegion {
        let regionIdentifier = "com.mumble.mburger.automation.trigger.region" + String(self.id)
        let lat = CLLocationDegrees(latitude)
        let lng = CLLocationDegrees(latitude)
        let radius = CLLocationDistance(self.radius)
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lng), radius: radius, identifier: regionIdentifier)
        return region
    }
    
    override func isValid(fromAppStartup: Bool) -> Bool {
        return completionDate == nil
    }
    
    // MARK: - Save & retrieve

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
