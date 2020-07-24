//
//  MBImagesElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// A convenience name for MBImages.
public typealias MBImage = MBFile

/// This class represents a MBurger images element.
public class MBImagesElement: MBElement {
    /// The images of the element.
    public let images: [MBImage]
    
    /// The first image of the element if exists.
    public var firstImage: MBImage? {
        return images.first
    }
    
    /// Initializes an image element with an elementId, a name, order and the text.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - generalValue: The `value` representing the element.
    ///   - type: The `type` of the element retuned by the api.
    public init(elementId: Int, elementName: String, order: Int, images: [MBImage]) {
        self.images = images
        super.init(elementId: elementId, elementName: elementName, type: .images, order: order)
    }
    
    /// Initializes an image element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        var dictionaryImages: [MBImage] = []
        if let values = dictionary["value"] as? [[String: Any]] {
            dictionaryImages = values.map { MBImage(dictionary: $0) }
        }
        images = dictionaryImages
        
        super.init(dictionary: dictionary)
    }
    
    enum CodingKeysElement: String, CodingKey {
        case images
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        
        images = try container.decode([MBImage].self, forKey: .images)
        
        try super.init(from: decoder)
    }
    
    /// Encodes a `MBImagesElement` to an `Encoder`
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(images, forKey: .images)
    }
}
