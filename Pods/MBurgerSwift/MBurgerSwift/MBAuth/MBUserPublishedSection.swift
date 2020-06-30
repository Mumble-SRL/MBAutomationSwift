//
//  MBUserPublishedSection.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 27/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// A section published by the user.
public struct MBUserPublishedSection: Codable {
    
    /// The id of the section.
    public let sectionId: Int

    /// The id of the block of the section.
    public let blockId: Int
    
    /// Initializes a published section object with the sectionId and blockId.
    /// - Parameters:
    ///   - sectionId: The `id` of the section.
    ///   - blockId: The `id` of the block of the section.
    init(sectionId: Int, blockId: Int) {
        self.sectionId = sectionId
        self.blockId = blockId
    }
    
    /// Initializes an object with the dictionary returned by the api.
    /// - Parameters:
    ///  - dictionary: The `Dictionary` returned from the APIs reponse.
    init(dictionary: [String: Any]) {
        sectionId = dictionary["id"] as? Int ?? 0
        blockId = dictionary["block_id"] as? Int ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case sectionId
        case blockId
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        sectionId = try container.decode(Int.self, forKey: .sectionId)
        blockId = try container.decode(Int.self, forKey: .blockId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(sectionId, forKey: .sectionId)
        try container.encode(blockId, forKey: .blockId)
    }
}
