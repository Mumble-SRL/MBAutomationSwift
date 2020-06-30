//
//  MBGeofenceParameter.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation
import CoreLocation

/// A parameter used to filter the elements retuned, the elements returned will be in the geofence square defined by the coordinates.
public struct MBGeofenceParameter: MBParameter {

    /// The upper-right corner of the square specified in cooridinate.
    let northEastCoordinate: CLLocationCoordinate2D
    
    /// The lower-left corner of the square specified in cooridinate.
    let southWestCoordinate: CLLocationCoordinate2D
    
    /// Initializes a geofence parameter.
    /// - Parameters:
    ///   - NECoordinate: The upper-right corner of the square specified in cooridinate.
    ///   - SWCoordinate: The lower-left corner of the square specified in cooridinate.
    public init(NECoordinate: CLLocationCoordinate2D, SWCoordinate: CLLocationCoordinate2D) {
        self.northEastCoordinate = NECoordinate
        self.southWestCoordinate = SWCoordinate
    }
    
    /// Initializes a geofence parameter.
    /// - Parameters:
    ///   - northEastLatitude: The latitude of the upper-right corner of the square.
    ///   - northEastLongitude: The longitude of the upper-right corner of the square.
    ///   - southWestLatitude: The latitude of the lower-left corner of the square.
    ///   - southWestLongitude: The longitude of the lower-left corner of the square.
    public init(northEastLatitude: Double, northEastLongitude: Double, southWestLatitude: Double, southWestLongitude: Double) {
        self.init(NECoordinate: CLLocationCoordinate2D(latitude: northEastLatitude, longitude: northEastLongitude),
                  SWCoordinate: CLLocationCoordinate2D(latitude: southWestLatitude, longitude: southWestLongitude))
    }
    
    public func parameterRepresentation() -> [String: Any] {
        let key = "filter[elements.geofence]"
        let value = "\(northEastCoordinate.latitude),\(southWestCoordinate.latitude),\(northEastCoordinate.longitude),\(southWestCoordinate.longitude)"
        return [
            key: value.urlEncoded()
        ]
    }
}

fileprivate extension String {
    func urlEncoded() -> String {
        var allowedChars = CharacterSet.urlQueryAllowed
        allowedChars.remove(charactersIn: "!*'();:@&=+$,/?%#[]")
        return addingPercentEncoding(withAllowedCharacters: allowedChars) ?? ""
    }
}
