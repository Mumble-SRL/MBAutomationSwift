//
//  MBTextElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a MBurger text element.
/// It is the counterpart of the 'text' and 'textarea' types on the dashboard
public class MBTextElement: MBElement {
    /// The value of the element.
    public let text: String
    
    /// Initializes a text element with the element id, name, type, order and text value.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - text: The `text` of the element.
    public init(elementId: Int, elementName: String, order: Int, text: String) {
        self.text = text
        super.init(elementId: elementId, elementName: elementName, type: .text, order: order)
    }
    
    /// Initializes a text element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        text = dictionary["value"] as? String ?? ""
        super.init(dictionary: dictionary)
    }
    
    enum CodingKeysElement: String, CodingKey {
        case text
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        
        text = try container.decode(String.self, forKey: .text)
        
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(text, forKey: .text)
    }
}
