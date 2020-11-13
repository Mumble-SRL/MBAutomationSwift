//
//  MBColorElement.swift
//  MBurgerSwift
//
//  Created by Lorenzo Oliveto on 06/05/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit

/// This class represents a MBurger color element.
public class MBColorElement: MBElement {
    /// The value of the element.
    public let colorHex: String
    
    /// Returns the color of this element
    public var color: UIColor? {
        return colorWithHexString(hexString: colorHex)
    }
    
    /// Initializes a color element with an elementId, a name, order and the color hex.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - colorHex: The `colorHex` of the element.
    init(elementId: Int, elementName: String, order: Int, colorHex: String) {
        self.colorHex = colorHex
        super.init(elementId: elementId, elementName: elementName, type: .color, order: order)
    }
    
    /// Initializes a markdown element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        self.colorHex = dictionary["value"] as? String ?? ""
        super.init(dictionary: dictionary)
    }
    
    // MARK: - Codable protocol
    enum CodingKeysElement: String, CodingKey {
        case colorHex
    }
    
    /// Initializes a `MBColorElement` from a `Decoder`
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        
        colorHex = try container.decode(String.self, forKey: .colorHex)
        
        try super.init(from: decoder)
    }
    
    /// Encodes a `MBColorElement` to an `Encoder`
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(colorHex, forKey: .colorHex)
    }
    
    private func colorWithHexString(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    private func intFromHexString(hexStr: String) -> UInt64 {
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        var rgbValue: UInt64 = 0
        if #available(iOS 13.0, *) {
            scanner.scanHexInt64(&rgbValue)
        } else {
            var rgb32: UInt32 = 0
            scanner.scanHexInt32(&rgb32)
            rgbValue = UInt64(rgb32)
        }
        return rgbValue
    }
    
}
