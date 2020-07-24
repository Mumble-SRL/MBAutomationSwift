//
//  MBRelationElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 07/10/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a MBurger relation element.
public class MBRelationElement: MBElement {
    /// The relations of this element.
    public let relations: [MBRelation]
        
    /// Initializes a relation element with an id, a name, an order and it's value.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - relations: The `relations` of the element.
    init(elementId: Int, elementName: String, order: Int, relations: [MBRelation]) {
        self.relations = relations
        super.init(elementId: elementId, elementName: elementName, type: .relation, order: order)
    }
    
    /// Initializes a relation element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        if let dictValue = dictionary["value"] as? [String: Any] {
            self.relations = [MBRelation(dictionary: dictValue)]
        } else if let arrayValue = dictionary["value"] as? [[String: Any]] {
            self.relations = arrayValue.map({ MBRelation(dictionary: $0) })
        } else {
            self.relations = []
        }
        super.init(dictionary: dictionary)
    }
    
    enum CodingKeysElement: String, CodingKey {
        case relations
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        relations = try container.decode([MBRelation].self, forKey: .relations)
        
        try super.init(from: decoder)
    }
    
    /// Encodes a `MBRelationElement` to an `Encoder`
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(relations, forKey: .relations)
    }
}

/// This class represents a relation in an MBurger relation element.
public class MBRelation: Codable, Equatable {
    /// The block id of the relation.
    public let blockId: Int
    
    /// The section id of the relation.
    public let sectionId: Int

    /// Initializes a relation with an block id, and section id.
    /// - Parameters:
    ///   - blockId: The `id` of the block to which is related.
    ///   - sectionId: The `id` of the section to which is related.
    init(blockId: Int, sectionId: Int) {
        self.blockId = blockId
        self.sectionId = sectionId
    }
    
    /// Initializes a relation element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        self.blockId = dictionary["block_id"] as? Int ?? 0
        self.sectionId = dictionary["section_id"] as? Int ?? 0
    }
        
    // MARK: - Equatable protocol
    public static func == (lhs: MBRelation, rhs: MBRelation) -> Bool {
        return lhs.blockId == rhs.blockId && lhs.sectionId == rhs.sectionId
    }

    // MARK: - Codable protocol
    enum CodingKeys: String, CodingKey {
        case blockId
        case sectionId
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        blockId = try container.decode(Int.self, forKey: .blockId)
        sectionId = try container.decode(Int.self, forKey: .sectionId)
    }
    
    /// Encodes a `MBRelation` to an `Encoder`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(blockId, forKey: .blockId)
        try container.encode(sectionId, forKey: .sectionId)
    }
}
