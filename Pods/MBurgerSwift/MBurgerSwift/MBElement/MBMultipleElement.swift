//
//  MBMultipleElement.swift
//  MBurgerSwift
//
//  Created by Lorenzo Oliveto on 22/07/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit

/// This class represents a MBurger multiple element, users can select multiple values from an array of options.
public class MBMultipleElement: MBElement {
    /// The possible options of this element.
    public let options: [MBMultipleElementOption]
    
    /// The selected options of this element.
    public let selectedOptions: [String]?

    /// Initializes a multiple element with the element id, name, order, options and, if there's the selected options.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - options: An Array of `MBMultipleElementOption` of the element.
    ///   - selectedOptions: The `options` selected.
    init(elementId: Int, elementName: String, order: Int, options: [MBMultipleElementOption], selectedOptions: [String]?) {
        self.options = options
        self.selectedOptions = selectedOptions
        
        super.init(elementId: elementId, elementName: elementName, type: .multiple, order: order)
    }

    /// Initializes a multiple element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        selectedOptions = dictionary["value"] as? [String] ?? nil
        if let optionsDict = dictionary["options"] as? [[String: Any]] {
            options = optionsDict.map { (option) -> MBMultipleElementOption in
                return MBMultipleElementOption(option)
            }
        } else {
            options = []
        }
        
        super.init(dictionary: dictionary)
    }

    // MARK: - Codable protocol
    enum CodingKeysElement: String, CodingKey {
        case options
        case selectedOptions
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        
        selectedOptions = try container.decodeIfPresent([String].self, forKey: .selectedOptions)
        options = try container.decode([MBMultipleElementOption].self, forKey: .options)
        
        try super.init(from: decoder)
    }
    
    /// Encodes a `MBMultipleElement` to an `Encoder`
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(options, forKey: .options)
        try container.encodeIfPresent(selectedOptions, forKey: .selectedOptions)
    }

}

/// This class represents an option that can be selected in a multiple element.
public class MBMultipleElementOption: Codable {
    /// The key of the option.
    public let key: String
    /// The value of the option.
    public let value: String
    
    /// Initializes a multiple element option with a key and a value.
    /// - Parameters:
    ///   - key: The `key` returned of the option.
    ///   - value: The `value` of the option.
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    /// Initializes the element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    init(_ dictionary: [String: Any]) {
        key = dictionary["key"] as? String ?? ""
        value = dictionary["value"] as? String ?? ""
    }
    
    // MARK: - Codable protocol
    enum CodingKeys: String, CodingKey {
        case key
        case value
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        key = try container.decode(String.self, forKey: .key)
        value = try container.decode(String.self, forKey: .value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(key, forKey: .key)
        try container.encode(value, forKey: .value)
    }
}
