//
//  MBGeneralElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a general MBurger element.
public class MBGeneralElement: MBElement {
    /// The value of the element.
    public let generalValue: Data?
    
    /// The type of the element retuned by the api.
    public let stringType: String?
    
    /// Initializes a general element with an elementId, a name, order and the text.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - generalValue: The `value` representing the element.
    ///   - type: The `type` of the element retuned by the api.
    init(elementId: Int, elementName: String, order: Int, generalValue: Data?, type: String?) {
        self.generalValue = generalValue
        self.stringType = type
        super.init(elementId: elementId, elementName: elementName, type: .undefined, order: order)
    }
    
    /// Initializes a general element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        generalValue = dictionary["value"] as? Data
        stringType = dictionary["type"] as? String
        super.init(dictionary: dictionary)
    }
    
    enum CodingKeysElement: String, CodingKey {
        case generalValue
        case type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        
        generalValue = try container.decodeIfPresent(Data.self, forKey: .generalValue)
        stringType = try container.decodeIfPresent(String.self, forKey: .type)
        
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encodeIfPresent(generalValue, forKey: .generalValue)
        try container.encodeIfPresent(stringType, forKey: .type)
    }
}
