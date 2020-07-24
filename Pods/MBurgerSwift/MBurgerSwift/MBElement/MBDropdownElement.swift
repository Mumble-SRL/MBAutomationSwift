//
//  MBDropdownElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a MBurger dropdown element.
public class MBDropdownElement: MBElement {
    /// The possible options of the dropdown.
    public let options: [MBDropdownElementOption]
    
    /// The selected option of the dropdown.
    public let selectedOption: String?
    
    /// Initializes a dropdown element with the element id, name, order, options and, if ther's a selected option, .
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - options: An Array of `MBDropdownElementOption` of the element.
    ///   - selectedOption: The `option` selected.
    init(elementId: Int, elementName: String, order: Int, options: [MBDropdownElementOption], selectedOption: String?) {
        self.options = options
        self.selectedOption = selectedOption
        
        super.init(elementId: elementId, elementName: elementName, type: .dropDown, order: order)
    }
    
    /// Initializes a dropdown element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        selectedOption = dictionary["value"] as? String ?? nil
        if let optionsDict = dictionary["options"] as? [[String: Any]] {
            options = optionsDict.map { (option) -> MBDropdownElementOption in
                return MBDropdownElementOption(option)
            }
        } else {
            options = []
        }
        
        super.init(dictionary: dictionary)
        
    }
    
    // MARK: - Codable protocol
    enum CodingKeysElement: String, CodingKey {
        case options
        case selectedOption
    }
    
    /// Initializes a `MBDropdownElement` from a `Decoder`
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        
        selectedOption = try container.decodeIfPresent(String.self, forKey: .selectedOption)
        options = try container.decode([MBDropdownElementOption].self, forKey: .options)
        
        try super.init(from: decoder)
    }
    
    /// Encodes a `MBDropdownElement` to an `Encoder`
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(options, forKey: .options)
        try container.encodeIfPresent(selectedOption, forKey: .selectedOption)
    }
}

/// This class represents an option that can be selected in a dropdown.
public class MBDropdownElementOption: Codable {
    /// The key of the option.
    public let key: String
    /// The value of the option.
    public let value: String
    
    /// Initializes a dropdown element option with a key and a value.
    /// - Parameters:
    ///   - key: The `key` returned of the option.
    ///   - value: The `value` of the option.
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    /// Initializes a the element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    init(_ dictionary: [String: Any]) {
        key = dictionary["key"] as? String ?? ""
        value = dictionary["value"] as? String ?? ""
    }
    
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
