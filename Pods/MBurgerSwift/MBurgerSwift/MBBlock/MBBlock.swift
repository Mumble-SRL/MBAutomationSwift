//
//  MBBlock.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represent a MBurger Block.
open class MBBlock: Codable, Equatable {
    /// The id of the block.
    let blockId: Int
    
    /// The title of the block.
    let title: String
    
    /// The subtitle of the block.
    let subtitle: String
    
    /// The order index of the block.
    let order: Int
    
    /// The sections of the block.
    let sections: [MBSection]?
    
    /// Initializes a block with a block id, title, subtitle, order and sections.
    /// - Parameters:
    ///   - blockId: The `id` of the block.
    ///   - title: The `title` of the block.
    ///   - subtitle: The `subtitle` of the block.
    ///   - order: The `id order` of the block.
    ///   - sections: A `[MBSection]` of the block. The default value, if block doesn't have a section, is `nil`
    init(blockId: Int, title: String, subtitle: String, order: Int, sections: [MBSection]? = nil) {
        self.blockId = blockId
        self.title = title
        self.subtitle = subtitle
        self.order = order
        self.sections = sections
    }
    
    /// Initializes a block with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    convenience init(_ dictionary: [String: Any]) {
        let blockId = dictionary["id"] as? Int ?? -1
        let blockTitle = dictionary["title"] as? String ?? ""
        let blockSubtitle = dictionary["subtitle"] as? String ?? ""
        let order = dictionary["order"] as? Int ?? -1
        var dictSections: [MBSection]?
        if let jsonSections = dictionary["sections"] as? [[String: Any]] {
            dictSections = []
            jsonSections.forEach({ dictSections?.append(MBSection($0)) })
        }
        
        self.init(blockId: blockId, title: blockTitle, subtitle: blockSubtitle, order: order, sections: dictSections)
    }
    
    // MARK: - Equatable Protocol
    public static func == (lhs: MBBlock, rhs: MBBlock) -> Bool {
        return lhs.blockId == rhs.blockId
    }
    
    // MARK: - Codable Protcol
    enum CodingKeys: String, CodingKey {
        case blockId
        case title
        case subtitle
        case order
        case sections
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        blockId = try container.decode(Int.self, forKey: .blockId)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        order = try container.decode(Int.self, forKey: .order)
        sections = try container.decodeIfPresent([MBSection].self, forKey: .sections)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(blockId, forKey: .blockId)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(order, forKey: .order)
        try container.encodeIfPresent(sections, forKey: .sections)
    }
}
