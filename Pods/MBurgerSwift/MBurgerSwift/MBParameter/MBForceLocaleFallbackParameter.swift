//
//  MBForceLocaleParameter.swift
//  MBurgerSwift
//
//  Created by Lorenzo Oliveto on 06/10/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// A parameter to force the locale fallback, if an element is empty the fallback will be returned instead
public struct MBForceLocaleFallbackParameter: MBParameter {
    /// Initializes a force locale fallback parameter
    public init() {}
    /// Returns the `Parameters` rapresentation of the object.
    public func parameterRepresentation() -> [String: Any] {
        return ["force_locale_fallback": "true"]
    }
}
