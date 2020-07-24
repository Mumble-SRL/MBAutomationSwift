//
//  MBCheckboxElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a MBurger checkbox element.
public class MBCheckboxElement: MBElement {
    
    /// If the checkbox element is checked or not.
    public let checked: Bool
    
    /// Initializes a checkbox element with an id, a name, an order and it's value.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - check: If the checkbox is checked.
    init(elementId: Int, elementName: String, order: Int, check: Bool) {
        self.checked = check
        super.init(elementId: elementId, elementName: elementName, type: .checkbox, order: order)
    }
    
    /// Initializes a checkbox element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        self.checked = dictionary["value"] as? Bool ?? false
        super.init(dictionary: dictionary)
    }
    
    // MARK: - Codable protocol
    enum CodingKeysElement: String, CodingKey {
        case checked
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        checked = try container.decode(Bool.self, forKey: .checked)
        
        try super.init(from: decoder)
    }
    
    /// Encodes a `MBCheckboxElement` to an `Encoder`
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(checked, forKey: .checked)
    }
}
