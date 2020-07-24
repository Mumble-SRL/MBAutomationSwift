//
//  MBPollElement.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a MBurger poll element, the property answers contains the answers the user can give to a the poll.
public class MBPollElement: MBElement {
    /// The possible answers for the poll.
    public let answers: [String]
    
    /// The expiration date of the poll.
    public let expirationDate: Date
    
    /// The results of the poll.
    public let results: [Int]?
 
    /// If I have answered.
    public let answered: Bool

    /// The answer.
    public let answer: Int?
    
    /// Initializes a poll element with an elementId, a name and the answers.
    /// - Parameters:
    ///   - elementId: The `id` of the element.
    ///   - elementName: The `name` of the element.
    ///   - order: The `id order` of the element.
    ///   - answers: The `answers` for the element.
    ///   - expirationDate: The `Date` at which the poll expires.
    ///   - results: The `results` of the poll.
    ///   - answered: If has answered at the poll.
    ///   - answer: The `answer` of the poll.
    init(elementId: Int,
         elementName: String,
         order: Int,
         answers: [String],
         expirationDate: Date,
         results: [Int]?,
         answered: Bool,
         answer: Int?) {
        self.answers = answers
        self.expirationDate = expirationDate
        self.results = results
        self.answered = answered
        self.answer = answer
        super.init(elementId: elementId, elementName: elementName, type: .poll, order: order)
    }
    
    /// Initializes a poll element with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    required init(dictionary: [String: Any]) {
        let valueDictionary = dictionary["value"] as? [String: Any] ?? [:]
        
        let answersFromApi = valueDictionary["answers"] as? [String] ?? [String]()
        
        var resultsFromApi = valueDictionary["results"] as? [Int] ?? [Int]()
        while resultsFromApi.count != answersFromApi.count {
            resultsFromApi.removeLast()
        }
        
        results = resultsFromApi
        answers = answersFromApi
        
        answer = valueDictionary["answer"] as? Int ?? nil
        answered = valueDictionary["answered"] as? Bool ?? false
        
        let expirationTimeInterval = valueDictionary["ends_at"] as? TimeInterval ?? 0
        expirationDate = Date(timeIntervalSince1970: expirationTimeInterval)
        
        super.init(dictionary: dictionary)
    }
    
    // MARK: - Codable
    enum CodingKeysElement: String, CodingKey {
        case answers
        case answered
        case answer
        case results
        case expirationDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysElement.self)
        
        answers = try container.decode([String].self, forKey: .answers)
        answered = try container.decode(Bool.self, forKey: .answered)
        results = try container.decodeIfPresent([Int].self, forKey: .results)
        expirationDate = try container.decode(Date.self, forKey: .expirationDate)
        answer = try container.decodeIfPresent(Int.self, forKey: .answer)
        try super.init(from: decoder)
    }
    
    /// Encodes a `MBPollElement` to an `Encoder`
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysElement.self)
        
        try container.encode(answers, forKey: .answers)
        try container.encode(answered, forKey: .answered)
        try container.encodeIfPresent(results, forKey: .results)
        try container.encode(expirationDate, forKey: .expirationDate)
        try container.encodeIfPresent(answer, forKey: .answer)
    }
}
