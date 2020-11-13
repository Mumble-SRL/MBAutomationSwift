//
//  MBOriginalMediaParameter.swift
//  MBurgerSwift
//
//  Created by Lorenzo Oliveto on 06/10/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit

/// A parameter to request original version of the images
public struct MBOriginalMediaParameter: MBParameter {
    /// Initializes an original media parameter
    public init() {}
    /// Returns the `Parameters` rapresentation of the object.
    public func parameterRepresentation() -> [String: Any] {
        return ["original_media": "true"]
    }
}
