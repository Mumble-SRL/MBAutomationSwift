//
//  MBProject.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// Represents a MBurger project.
public struct MBProject: Codable, Equatable {
    
    /// The id of the project.
    public let projectId: Int
   
    /// The name of the project.
    public let projectName: String
    
    /// The legal contracts of the project.
    public let contracts: [MBLegalContract]?
    
    /// Initializes a project with a projectId and the name.
    /// - Parameters:
    ///   - id: The `id` of the project.
    ///   - name: The `name` of the project.
    ///   - legalContracts: The legal contracts of the project. The default value is `nil`.
    init(id: Int, name: String, legalContracts: [MBLegalContract]? = nil) {
        projectId = id
        projectName = name
        contracts = legalContracts
    }
    
    /// Initializes a project with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    init(dictionary: [String: Any]) {
        projectId = dictionary["id"] as? Int ?? 0
        projectName = dictionary["name"] as? String ?? ""
        if let contractsDict = dictionary["contracts"] as? [[String: Any]] {
            contracts = contractsDict.map { (contract) -> MBLegalContract in
                return MBLegalContract(dictionary: contract)
            }
        } else {
            contracts = nil
        }
    }
    
    // MARK: - Equatable Protocol
    public static func == (lhs: MBProject, rhs: MBProject) -> Bool {
        return lhs.projectId == rhs.projectId
    }
    
    // MARK: - Codable protocol
    enum CodingKeys: String, CodingKey {
        case projectId
        case projectName
        case contracts
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        projectId = try container.decode(Int.self, forKey: .projectId)
        projectName = try container.decode(String.self, forKey: .projectName)
        contracts = try container.decodeIfPresent([MBLegalContract].self, forKey: .contracts)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(projectId, forKey: .projectId)
        try container.encode(projectName, forKey: .projectName)
        try container.encodeIfPresent(contracts, forKey: .contracts)
    }
}
