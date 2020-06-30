//
//  MBPaginationInfo.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class contains meta information abaut the pagination, it's usually returned when an array is requested by the api.
public struct MBPaginationInfo {
    
    /// The starting index.
    public let from: Int
    
    /// The ending index.
    public let to: Int
    
    /// The total number of elements of that type on MBurger.
    public let total: Int
    
    /// Initializes a meta pagination info with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    init(dictionary: [String: Any]) {
        from = dictionary["from"] as? Int ?? 0
        to = dictionary["to"] as? Int ?? 0
        total = dictionary["total"] as? Int ?? 0
    }
    
    /// Initializes a meta pagination info.
    /// - Parameters:
    ///   - from: The starting index.
    ///   - to: The ending index.
    ///   - total: The total number of elements of that type on MBurger.
    init(from: Int, to: Int, total: Int) {
        self.from = from
        self.to = to
        self.total = total
    }
}
