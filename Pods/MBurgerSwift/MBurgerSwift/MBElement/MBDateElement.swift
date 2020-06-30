//
//  MBDateElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a MBurger date element.
public class MBDateElement: MBElement {
    
    /// The value of the element.
    public let date: Date
    
    /// Initializes a date element with an elementId, a name, order and a date.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - date: The `date` of the element.
    init(elementId: Int, elementName: String, order: Int, date: Date) {
        self.date = date
        super.init(elementId: elementId, elementName: elementName, type: .date, order: order)
    }
    
    /// Initializes a date element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dateString = dictionary["value"] as? String ?? ""
        date = dateFormatter.date(from: dateString) ?? Date()
        super.init(dictionary: dictionary)
    }
    
    enum CodingKeysElement: String, CodingKey {
        case date
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        
        date = try container.decode(Date.self, forKey: .date)
        
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(date, forKey: .date)
    }
}
