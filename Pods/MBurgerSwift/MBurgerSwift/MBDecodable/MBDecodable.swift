//
//  MBDecodable.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 22/10/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// A protocol that extends the standard Decodable protocol for to simplify the MBurger decoding.
public protocol MBDecodable: Decodable {
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    init(from decoder: MBDecoder) throws
}
