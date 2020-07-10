//
//  MBAppOpeningTrigger.swift
//  MBMessages
//
//  Created by Lorenzo Oliveto on 06/07/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBAudienceSwift

public class MBAppOpeningTrigger: MBTrigger {
    public let times: Int
    
    init(id: String,
         times: Int) {
        self.times = times
        super.init(id: id, type: .appOpening)
    }

    convenience init(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let times = dictionary["times"] as? Int ?? 0

        self.init(id: id,
                  times: times)
    }

    override func isValid(fromAppStartup: Bool) -> Bool {
        guard fromAppStartup else {
            return false
        }
        let currentSession = MBAudience.currentSession()
        return currentSession >= times
    }

    //MARK: - Save & retrieve

    convenience init(fromJsonDictionary dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let times = dictionary["times"] as? Int ?? 0
        self.init(id: id, times: times)
    }
    
    override func toJsonDictionary() -> [String : Any] {
        var dictionary = super.toJsonDictionary()
        dictionary["times"] = times
        return dictionary
    }
}
