//
//  MBImageFormatParameter.swift
//  MBurgerSwift
//
//  Created by Lorenzo Oliveto on 06/10/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit

/// The images format available for MBurger
public enum MBImageFormat: String {
    /// Original image
    case original
    /// Thumb image
    case thumb
    /// Medium image
    case medium
    /// Large image
    case large
}

/// A parameter to request a particular format for the images
public struct MBImageFormatParameter: MBParameter {
    /// The format that will be requested to
    let format: MBImageFormat
    
    /// Initializes a new image format parameter with the parameters passed
    public init(format: MBImageFormat) {
        self.format = format
    }
    
    /// Returns the `Parameters` rapresentation of the object.
    public func parameterRepresentation() -> [String: Any] {
        return ["image_format": format.rawValue]
    }
}
