//
//  MBLocationTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

public class MBLocationTrigger: MBTrigger {
    public let address: String
    public let latitude: Float
    public let longitude: Float
    
    public let radius: Float
    public let after: TimeInterval
    
    init(id: String,
         address: String,
         latitude: Float,
         longitude: Float,
         radius: Float,
         after: TimeInterval) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.after = after
        super.init(id: id, type: .location)
    }
    
    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let address = dictionary["address"] as? String ?? ""
        let latitudeNumber = dictionary["latitude"] as? NSNumber
        let longitudeNumber = dictionary["longitude"] as? NSNumber
        let radius = dictionary["radius"] as? Float ?? 0
        let after = dictionary["after"] as? TimeInterval ?? 0

        self.init(id: id,
                  address: address,
                  latitude: latitudeNumber?.floatValue ?? 0,
                  longitude: longitudeNumber?.floatValue ?? 0,
                  radius: radius,
                  after: after)
    }
    
    override func isValid(fromAppStartup: Bool) -> Bool {
        return true
    }
    
    //MARK: - Save & retrieve

    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let address = dictionary["address"] as? String ?? ""
        let latitude = dictionary["latitude"] as? Float ?? 0
        let longitude = dictionary["longitude"] as? Float ?? 0
        let radius = dictionary["radius"] as? Float ?? 0
        let after = dictionary["after"] as? TimeInterval ?? 0
        self.init(id: id,
                  address: address,
                  latitude: latitude,
                  longitude: longitude,
                  radius: radius,
                  after: after)
    }

    override func toJsonDictionary() -> [String : Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["address"] = address
        dictionary["latitude"] = latitude
        dictionary["longitude"] = longitude
        dictionary["radius"] = radius
        dictionary["after"] = after

        return dictionary
    }

}
