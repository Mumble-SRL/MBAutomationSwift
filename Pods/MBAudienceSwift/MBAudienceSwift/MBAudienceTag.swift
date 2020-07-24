//
//  MBTag.swift
//  MBurgerSwift
//
//  Created by Lorenzo Oliveto on 09/04/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit

class MBAudienceTag: NSObject {
    @objc let tag: String!
    @objc var value: String!
    
    @objc init(tag: String, value: String!) {
        self.tag = tag
        self.value = value
    }
    
    convenience init (dictionary: [String: String]) {
        let tag = dictionary["tag"] ?? ""
        let value = dictionary["value"] ?? ""
        self.init(tag: tag, value: value)
    }
    
    func toDictionary() -> [String: String] {
        return ["tag": tag, "value": value]
    }
    
}
