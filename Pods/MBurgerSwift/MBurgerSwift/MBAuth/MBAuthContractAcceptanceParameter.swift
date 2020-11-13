//
//  MBAuthContractAcceptanceParameter.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 27/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation
import MBNetworkingSwift

/// A parameter that can be passed to the APIs that indicates if a legal contract has been accepted or not.
public class MBAuthContractAcceptanceParameter: MBParameter {
    
    /// The id of the contract.
    public let contractId: Int
    
    /// If the contract has been accepted or not.
    public let accepted: Bool
    
    /// Initializes the object with the contract id and the acceptance flag.
    /// - Parameters:
    ///   - contractId: The `id` of the contract
    ///   - accepted: If the contract has been accepted or not.
    public init(contractId: Int, accepted: Bool) {
        self.contractId = contractId
        self.accepted = accepted
    }
    
    /// Returns the `Parameters` rapresentation of the object.
    public func parameterRepresentation() -> Parameters {
        return ["id": contractId, "accepted": accepted]
    }
}
