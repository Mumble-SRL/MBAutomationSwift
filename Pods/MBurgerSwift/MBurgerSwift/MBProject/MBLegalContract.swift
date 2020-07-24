//
//  MBLegalContract.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// Represents a Legal contract in MBurger.
public struct MBLegalContract: Codable, Equatable {
    
    /// The id of the contract.
    let contractId: Int

    /// The name of the contract.
    let contractName: String
    
    /// The link of the contract, if setted.
    var link: String?
    
    /// The text of the contract.
    var text: String?
    
    /// If the contract is active or not.
    let isActive: Bool
    
    /// The creation date of the contract.
    let creationDate: Date
    
    /// The update date of the contract.
    let updateDate: Date
    
    /// Initializes a project with a projectId and the name.
    /// - Parameters:
    ///   - contractId: The `id` of the contract.
    ///   - name: The `name` of the contract.
    ///   - contractLink: The `link` of the contract of the project, `nil` by default
    ///   - text: The `text` of the contract, `nil` by default
    ///   - active: If the contract is active or not.
    ///   - creationDate: The creation date of the contract.
    ///   - updateDate: The update date of the contract.
    init(contractId: Int, name: String, contractLink: String?, text: String?, active: Bool, creationDate: Date, updateDate: Date) {
        self.contractId = contractId
        self.contractName = name
        self.link = contractLink
        self.text = text
        self.isActive = active
        self.creationDate = creationDate
        self.updateDate = updateDate
    }
    
    /// Initializes a contract with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse.
    init(dictionary: [String: Any]) {
        let contractId = dictionary["id"] as? Int ?? -1
        let contractName = dictionary["name"] as? String ?? ""
        let text = dictionary["text"] as? String ?? nil
        let link = dictionary["link"] as? String ?? nil
        let active = dictionary["active"] as? Bool ?? false
        let creationTimeInterval = dictionary["created_at"] as? TimeInterval ?? 0.0
        let creationDate = Date(timeIntervalSince1970: creationTimeInterval)
        let updateTimeInterval = dictionary["updated_at"] as? TimeInterval ?? 0.0
        let updateDate = Date(timeIntervalSince1970: updateTimeInterval)
        
        self.init(contractId: contractId,
                  name: contractName,
                  contractLink: link,
                  text: text,
                  active: active,
                  creationDate: creationDate,
                  updateDate: updateDate)
    }
    
    // MARK: - Equatable protocol
    public static func == (lhs: MBLegalContract, rhs: MBLegalContract) -> Bool {
        return lhs.contractId == rhs.contractId
    }
}
