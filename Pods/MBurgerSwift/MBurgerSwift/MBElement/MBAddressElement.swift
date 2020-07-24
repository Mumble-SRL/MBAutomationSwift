//
//  MBAddressElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation
import CoreLocation

/// This class represents a MBurger address element.
public class MBAddressElement: MBElement {
    /// The value of the element.
    public let address: String
    
    /// The coordinate of the address.
    public let coordinate: CLLocationCoordinate2D
    
    /// The latitude of the address.
    public var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    /// The longitude of the address.
    public var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    /// Initializes an address element with an elementId, a name, order, address, latitude and longitude.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - address: The `address` of the element.
    ///   - latitude: The latitude expressed in CLLocationDegrees.
    ///   - longitude: The longitude expressed in CLLocationDegrees.
    init(elementId: Int, elementName: String, order: Int, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.address = address
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        super.init(elementId: elementId, elementName: elementName, type: .address, order: order)
    }

    /// Initializes an address element with an elementId, a name, order, address and it's coordinates.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - address: The `address` of the element.
    ///   - coordinate: The coordinate.
    init(elementId: Int, elementName: String, order: Int, address: String, coordinate: CLLocationCoordinate2D) {
        self.address = address
        self.coordinate = coordinate
        super.init(elementId: elementId, elementName: elementName, type: .address, order: order)
    }
    
    /// Initializes an address element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        let addressDictionary = dictionary["value"] as? [String: Any] ?? nil
        self.address = addressDictionary?["address"] as? String ?? ""
        
        let latitude = addressDictionary?["latitude"] as? Double ?? 0
        let longitude = addressDictionary?["longitude"] as? Double ?? 0
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        super.init(dictionary: dictionary)
    }
    
    enum CodingKeysElement: String, CodingKey {
        case address
        case latitude
        case longitude
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)

        address = try container.decode(String.self, forKey: .address)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        try super.init(from: decoder)
    }

    /// Encodes a `MBAddressElement` to an `Encoder`
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)

        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}
