//
//  MBUser.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 27/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// An object representing the user informations.
public struct MBUser: Codable, Equatable {
    
    ///The id of the user.
    public let userId: Int
    
    /// The name of the user.
    public let name: String

    /// The surname of the user.
    public let surname: String
    
    /// The email of the user. It is unique for every user in your project.
    public let email: String

    /// The phone number of the user.
    public var phone: String?

    /// The url of the profile image.
    public var imageURL: URL?

    /// Additional data if passed when the user is registered.
    public var data: [String: Any]?
    
    /// Dictionary of objects that can be used by the plugins to add data to the user.
    public var pluginsObjects: [String: Any]?

    /// An array of object representing the status of acceptance of the legal contracts of the project.
    public var contracts: [MBUserContractStatus]?
   
    /// An array of object representing all the sections published by the user.
    public var publishedSections: [MBUserPublishedSection]?
    
    /// Initializes the object with the provided parameters.
    /// - Parameters:
    ///   - userId: The `Int id` of the user.
    ///   - name: The `nameString` of the user.
    ///   - surname: The `surnameString` of the user.
    ///   - email: The `emailString` of the user.
    ///   - phone: The `phoneString` of the user, `nil` by default.
    ///   - imageUrl: The `URL` of the image, `nil` by default.
    ///   - contracts: The `[MBUserContractStatus]` accepted by the user, `nil` by default.
    ///   - publishedSections: The `[MBUserPublishedSection]` accepted by the user, `nil` by default.
    ///   - data: The `Dictionary` of additional data of the user to save, `nil` by default.
    init(userId: Int, name: String, surname: String, email: String, phone: String?, imageUrl: URL?, contracts: [MBUserContractStatus]?, publishedSections: [MBUserPublishedSection]?, data: [String: Any]?) {
        self.userId = userId
        self.name = name
        self.surname = surname
        self.email = email
        self.phone = phone
        self.imageURL = imageUrl
        self.contracts = contracts
        self.publishedSections = publishedSections
        self.data = data
    }
    
    /// Initializes a user with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    init(dictionary: [String: Any]) {
        userId = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        surname = dictionary["surname"] as? String ?? ""
        email = dictionary["email"] as? String ?? ""
        phone = dictionary["phone"] as? String ?? nil
        if let image = dictionary["image"] as? String {
            imageURL = URL(string: image)
        }
        
        if let contractsFromDictionary = dictionary["contracts"] as? [[String: Any]] {
            contracts = contractsFromDictionary.map { MBUserContractStatus(dictionary: $0) }
        }
        
        if let publishedSectionsFromDictionary = dictionary["published_sections"] as? [[String: Any]], publishedSectionsFromDictionary.count != 0 {
            publishedSections = publishedSectionsFromDictionary.map { MBUserPublishedSection(dictionary: $0) }
        }
        
        data = dictionary["data"] as? [String: Any]
    }
    
    // MARK: - Equatable protocol
    public static func == (lhs: MBUser, rhs: MBUser) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    // MARK: - Codable protocol
    enum CodingKeys: String, CodingKey {
        case userId
        case name
        case surname
        case email
        case phone
        case imageURL
        case contracts
        case publishedSections
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userId = try container.decode(Int.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        surname = try container.decode(String.self, forKey: .surname)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        contracts = try container.decodeIfPresent([MBUserContractStatus].self, forKey: .contracts)
        publishedSections = try container.decodeIfPresent([MBUserPublishedSection].self, forKey: .publishedSections)
        if let dictionaryData = try container.decodeIfPresent(Data.self, forKey: .data) {
            data = try JSONSerialization.jsonObject(with: dictionaryData, options: []) as? [String: Any]
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(surname, forKey: .surname)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(contracts, forKey: .contracts)
        try container.encodeIfPresent(publishedSections, forKey: .publishedSections)
        if let dataPresent = data, let dictionaryData = dictionaryToData(dataPresent) {
            try container.encodeIfPresent(dictionaryData, forKey: .data)
        }
    }
    
    func dictionaryToData(_ dict: [String: Any]) -> Data? {
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: self, options: [])
            return serializedData
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
