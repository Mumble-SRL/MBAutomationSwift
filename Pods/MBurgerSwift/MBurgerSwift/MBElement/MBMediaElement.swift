//
//  MBMediaElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// The type of the media.
public enum MBMediaType: Int, Codable {
    
    /// A general file.
    case file = 0
    
    /// An audio.
    case audio = 1
    
    /// A video.
    case video = 2
    
    /// A document(e.g. PDF).
    case document = 3
    
    init(string: String) {
        switch string.lowercased() {
        case "audio": self = .audio
        case "video": self = .video
        case "document": self = .document
        case "file": self = .file
        default: self = .file
        }
    }
}

/// This class represents a MBurger media element.
public class MBMediaElement: MBElement {
    /// The type of media.
    public let mediaType: MBMediaType
    
    /// The medias of the element.
    public let medias: [MBMedia]
    
    /// The first media of the element if exists.
    public var firstMedia: MBMedia? {
        return medias.first
    }
    
    /// Initializes an image element with an id, name, order, the type of the media and an array of MBMedia.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - type: The `MBMediaType` of the media.
    ///   - media: The medias.
    init(elementId: Int, elementName: String, order: Int, type: MBMediaType, media: [MBMedia]) {
        self.mediaType = type
        self.medias = media
        super.init(elementId: elementId, elementName: elementName, type: .media, order: order)
    }
    
    /// Initializes an image element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        let stringType = dictionary["type"] as? String ?? ""
        self.mediaType = MBMediaType(string: stringType)
        
        var dictionaryMedias: [MBMedia] = []
        if let medias = dictionary["value"] as? [[String: Any]] {
            dictionaryMedias = medias.map { MBMedia(dictionary: $0) }
        }
        self.medias = dictionaryMedias
        
        super.init(dictionary: dictionary)
    }
    
    enum CodingKeysElement: String, CodingKey {
        case mediaType
        case medias
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        
        medias = try container.decode([MBMedia].self, forKey: .medias)
        mediaType = try container.decode(MBMediaType.self, forKey: .mediaType)
        
        try super.init(from: decoder)
    }
    
    /// Encodes a `MBMediaElement` to an `Encoder`
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(medias, forKey: .medias)
        try container.encode(mediaType, forKey: .mediaType)
    }
}
