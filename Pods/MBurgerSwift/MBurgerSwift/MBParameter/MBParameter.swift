//
//  MBParameter.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation
import MBNetworkingSwift

/// This protocol represent a parameter passed to the MBurger api.
public protocol MBParameter {
    
    /// returns Parameters value of elements that represents the parameter.
    func parameterRepresentation() -> Parameters
}
