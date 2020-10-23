//
//  MBLocationTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import CoreLocation
import MBMessagesSwift

/// A location trigger, fires if the user enters a region
public class MBLocationTrigger: MBTrigger {
    
    /// The address of the trigger
    public let address: String
    /// The latitude of the trigger
    public let latitude: Float
    /// The longitude of the trigger
    public let longitude: Float
    
    /// The radius of the region in meters
    public let radius: Float
    
    /// A delay in days for this trigger
    public let afterDays: Int
    
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
         afterDays: Int) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.afterDays = afterDays
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
        let afterDays = dictionary["after"] as? Int ?? 0
        
        self.init(id: id,
                  address: address,
                  latitude: latitudeNumber?.floatValue ?? 0,
                  longitude: longitudeNumber?.floatValue ?? 0,
                  radius: radius,
                  afterDays: afterDays)
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
        if isInside {
            if let lastLocation = lastLocation {
                let lastLocationIsInside = triggerRegion.contains(lastLocation)
                locationTriggerSatisfied = !lastLocationIsInside
            } else {
                locationTriggerSatisfied = true
            }
        }
        if locationTriggerSatisfied {
            if afterDays == 0 {
                completionDate = Date()
                return true
            } else {
                let calendar = Calendar.current
                if let dateByAddingDays = calendar.date(byAdding: .day, value: afterDays, to: Date()) {
                    completionDate = dateByAddingDays
                } else {
                    completionDate = Date()
                }
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
    ///   - message: the message that requested if this trigger is valid
    ///   - fromAppStartup: if this function is called from startup
    /// - Returns: If this trigger is valid
    override func isValid(message: MBMessage, fromAppStartup: Bool) -> Bool {
        // Push notification are handled by the server of MBurger
        guard message.type != .push else {
            return false
        }
        guard let completionDate = completionDate else {
            return false
        }
        return completionDate >= Date()
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
        let afterDays = dictionary["afterDays"] as? Int ?? 0
        self.init(id: id,
                  address: address,
                  latitude: latitude,
                  longitude: longitude,
                  radius: radius,
                  afterDays: afterDays)
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
        dictionary["afterDays"] = afterDays

        if let completionDate = completionDate {
            dictionary["completionDate"] = completionDate.timeIntervalSince1970
        }
        return dictionary
    }
    
    // MARK: - Trigger Update
        
    override internal func updatedTrigger(newTrigger: MBTrigger) -> MBTrigger {
        guard let newLocationTrigger = newTrigger as? MBLocationTrigger else {
            return newTrigger
        }
        
        newLocationTrigger.completionDate = completionDate
        return newLocationTrigger
    }

}
