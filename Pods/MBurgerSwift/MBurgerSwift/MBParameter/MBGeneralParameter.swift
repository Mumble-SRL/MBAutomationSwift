//
//  MBGeneralParameter.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

public struct MBGeneralParameter: MBParameter {
    /// The key of the parameter.
    let key: String
    
    /// The value of the parameter.
    let value: String
    
    /// Initializes a general parameter.
    /// - Parameters:
    ///   - field: The `field` used to filter.
    ///   - value: The `value` used to filter the elements.
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    public func parameterRepresentation() -> [String: Any] {
        return [key: value]
    }
}
