//
//  MBPaginationParameter.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// A parameter used to paginate the elements retuned.
public struct MBPaginationParameter: MBParameter {
    /// The number of elements to skip.
    let skip: Int
    
    /// The number of elements to take.
    let take: Int
    
    /// Initializes a geofence parameter.
    /// - Parameters:
    ///   - skip: The number of elements to skip.
    ///   - take: The number of elements to take.
    public init(skip: Int, take: Int) {
        self.skip = skip
        self.take = take
    }
    
    /// Returns the `Parameters` rapresentation of the object.
    public func parameterRepresentation() -> [String: Any] {
        return [
            "skip": skip,
            "take": take
        ]
    }
}
