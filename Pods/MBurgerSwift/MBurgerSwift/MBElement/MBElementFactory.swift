//
//  MBElementFactory.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This struct is used to create a `MBElement` objects based on the API's response
public struct MBElementFactory {
    /// Returns a MBElement object based on the type specified in the dictionary.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the API's reponse, if the type field of the dictionary cannot be represented by the implemented type of the SDK this functions returns a MBGeneralElement.
    public static func element(forDictionary dictionary: [String: Any]) -> MBElement {
        let type = dictionary["type"] as? String ?? ""
        
        switch type {
        case "text", "textarea":
            return MBTextElement(dictionary: dictionary)
        case "image":
            return MBImagesElement(dictionary: dictionary)
        case "checkbox":
            return MBCheckboxElement(dictionary: dictionary)
        case "dropdown":
            return MBDropdownElement(dictionary: dictionary)
        case "address":
            return MBAddressElement(dictionary: dictionary)
        case "markdown":
            return MBMarkdownElement(dictionary: dictionary)
        case "media", "audio", "video", "file", "document":
            return MBMediaElement(dictionary: dictionary)
        case "poll":
            return MBPollElement(dictionary: dictionary)
        case "datetime":
            return MBDateElement(dictionary: dictionary)
        case "relation":
            return MBRelationElement(dictionary: dictionary)
        case "color":
            return MBColorElement(dictionary: dictionary)
        default:
            return MBGeneralElement(dictionary: dictionary)
        }
    }
}
