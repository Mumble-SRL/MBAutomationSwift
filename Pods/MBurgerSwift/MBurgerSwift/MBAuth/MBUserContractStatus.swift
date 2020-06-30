//
//  MBUserContractStatus.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 27/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// A struct indicating if a legal contract has been accepted by the user.
public struct MBUserContractStatus: Codable {
    
    /// The id of the contract.
    public let contractId: Int
    
    /// If the contract has been accepted or not.
    public let accepted: Bool
    
    /// Initializes the parameter with the contract id and the acceptance flag.
    /// - Parameters:
    ///   - contractId: The id of the contract
    ///   - accepted: If the contract has been accepted or not.
    init(contractId: Int, isAccepted: Bool) {
        self.contractId = contractId
        accepted = isAccepted
    }
    
    /// Initializes the parameter with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    init(dictionary: [String: Any]) {
        contractId = dictionary["id"] as? Int ?? 0
        accepted = dictionary["accepted"] as? Bool ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case contractId
        case accepted
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        contractId = try container.decode(Int.self, forKey: .contractId)
        accepted = try container.decode(Bool.self, forKey: .accepted)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(contractId, forKey: .contractId)
        try container.encode(accepted, forKey: .accepted)
    }
}
