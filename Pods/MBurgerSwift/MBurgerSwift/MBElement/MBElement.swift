//
//  MBElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents the base class for all MBurger elements. All the specialized elements are subclasses of this class.
public class MBElement: MBElementProtocol {
    /// The order of the element.
    public var order: Int
    
    /// The id of the element.
    public var id: Int
    
    /// The type of the element.
    public var type: MBElementType
    
    /// The name of the element.
    public var name: String
    
    /// Initializes an element with an element id, name, type and order.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - type: The `MBElementType` of the element.
    ///   - order: The `id order` of the element.
    public init(elementId: Int, elementName: String, type: MBElementType, order: Int) {
        self.id = elementId
        self.order = order
        self.name = elementName
        self.type = type
    }
    
    /// Initializes an element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required public init(dictionary: [String: Any]) {
        order = dictionary["order"] as? Int ?? -1
        name = dictionary["name"] as? String ?? ""
        id = dictionary["id"] as? Int ?? -1
        let dictionaryType = dictionary["type"] as? String ?? ""
        type = MBElementType(string: dictionaryType)
    }
    
    public static func == (lhs: MBElement, rhs: MBElement) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Codable Protocol
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case order
        case type
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        order = try container.decode(Int.self, forKey: .order)
        type = try container.decode(MBElementType.self, forKey: .type)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(order, forKey: .order)
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}

extension Array where Element: MBElement {
    func toDict() -> [String: Any] {
        let dictionary = reduce(into: [String: Any]()) { (_, _) in
            
        }
        return dictionary
    }
}
