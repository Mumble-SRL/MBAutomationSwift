//
//  MBElementProtocol.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// A protocol to which all MBElements needs to be conform, it has all the basic data that a MBElement needs.
public protocol MBElementProtocol: Codable, Equatable {
    /// The order of the element
    var order: Int { get }
    /// The id of the element
    var id: Int { get }
    /// The type of the element
    var type: MBElementType { get }
    /// The name of the element
    var name: String { get set }
    
    /// Initializes a element from the dicttionary returned by APIs
    init(dictionary: [String: Any])
}

/// The type of elements.
public enum MBElementType: Int, Codable {
    /// Used when the type of the element can't be defined.
    case undefined = 0
    /// A text element.
    case text = 1
    /// An image element.
    case images = 2
    /// A general media element.
    case media = 3
    /// A checkbox element.
    case checkbox = 4
    /// A date element.
    case date = 5
    /// An address element.
    case address = 6
    /// A dropdown element.
    case dropDown = 7
    /// A poll element.
    case poll = 8
    /// A markdown element.
    case markdown = 9
    /// A relation element.
    case relation = 10
    /// A color element.
    case color = 11
    /// A multiple element.
    case multiple = 12

    init(string: String) {
        switch string.lowercased() {
        case "text", "textarea": self = .text
        case "image": self = .images
        case "audio", "video", "document", "file", "media": self = .media
        case "checkbox": self = .checkbox
        case "datetime": self = .date
        case "address": self = .address
        case "dropdown": self = .dropDown
        case "poll": self = .poll
        case "markdown": self = .markdown
        case "relation": self = .relation
        case "multiple": self = .multiple
        default: self = .undefined
        }
    }
}
