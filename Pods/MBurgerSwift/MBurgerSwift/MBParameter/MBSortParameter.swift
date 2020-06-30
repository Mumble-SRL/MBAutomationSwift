//
//  MBSortParameter.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// A parameter used to sort the elements retuned.
public struct MBSortParameter: MBParameter {
    /// The filed of the element used to sort.
    let field: String
    
    /// If the elements should be sorted in ascending order.
    let ascending: Bool
    
    /// Initializes a sort parameter.
    /// - Parameters:
    ///   - field: The field of the element used to sort.
    ///   - ascending: If the elements should be sorted in ascending order. The default value is `true`
    public init(field: String, ascending: Bool = true) {
        self.field = field
        self.ascending = ascending
    }
    
    public func parameterRepresentation() -> [String: Any] {
        let value = ascending ? field : "-\(field)"
        return [
            "sort": value
        ]
    }
}
