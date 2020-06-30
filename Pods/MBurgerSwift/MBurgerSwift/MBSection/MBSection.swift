//
//  MBSection.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a MBurger section.
public class MBSection: Codable, Equatable {
    /// The id of the section.
    public let sectionId: Int
    
    /// The order of the section.
    public let order: Int
    
    /// The elements of the section. The key of the dictionary is the name of the element, the value is an instance of a MBElement that represents the object.
    public let elements: [String: MBElement]?
    
    /// The date the section is available.
    public let availableAt: Date
    
    /// Indicates if the section is in evidence.
    public let inEvidence: Bool
    
    /// Initializes the section object with the section id, order, the elements(if present), the availability date and if is in evidence or not.
    /// - Parameters:
    ///   - sectionId: The `id` of the section
    ///   - order: The `id order` of the section.
    ///   - elements: A `Dictionary` that has as key the name of the element and as value a MBElement
    ///   - availableAt: The `Date` at which the section will be available.
    ///   - inEvidence: Indicates if the section is in evidence.
    public init(sectionId: Int,
                order: Int,
                elements: [String: MBElement]?,
                availableAt: Date,
                inEvidence: Bool) {
        self.sectionId = sectionId
        self.order = order
        self.elements = elements
        self.availableAt = availableAt
        self.inEvidence = inEvidence
    }
    
    /// Initializes a section with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    convenience init(_ dictionary: [String: Any]) {
        let sectionId = dictionary["id"] as? Int ?? -1
        let order = dictionary["order"] as? Int ?? -1
        
        var dictionaryElements: [String: MBElement]?
        if let elements = dictionary["elements"] as? [String: Any] {
            dictionaryElements = [:]
            for (key, value) in elements {
                if let element = value as? [String: Any] {
                    dictionaryElements?[key] = MBElementFactory.element(forDictionary: element)
                }
            }
        }
        
        let available = dictionary["available_at"] as? Double ?? 0
        let availableDate = Date(timeIntervalSince1970: available)
        let evidence = dictionary["in_evidence"] as? Bool ?? false
        
        self.init(sectionId: sectionId, order: order, elements: dictionaryElements, availableAt: availableDate, inEvidence: evidence)
    }
    
    // MARK: - Equatable Protocol
    public static func == (lhs: MBSection, rhs: MBSection) -> Bool {
        return lhs.sectionId == rhs.sectionId
    }
    
    // MARK: - Codable Protocol
    enum CodingKeys: String, CodingKey {
        case sectionId
        case order
        case elements
        case availableAt
        case inEvidence
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sectionId = try container.decode(Int.self, forKey: .sectionId)
        order = try container.decode(Int.self, forKey: .order)
        availableAt = try container.decode(Date.self, forKey: .availableAt)
        elements = try container.decodeIfPresent([String: MBElement].self, forKey: .elements)
        inEvidence = try container.decode(Bool.self, forKey: .inEvidence)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(sectionId, forKey: .sectionId)
        try container.encode(order, forKey: .order)
        try container.encode(availableAt, forKey: .availableAt)
        try container.encodeIfPresent(elements, forKey: .elements)
        try container.encode(inEvidence, forKey: .inEvidence)
    }
    
    func mapElements<T: Decodable>(toObject object: T.Type, withMapping: [String: String]) throws -> T {
        return try JSONDecoder().decode(object, from: Data())
    }
}
