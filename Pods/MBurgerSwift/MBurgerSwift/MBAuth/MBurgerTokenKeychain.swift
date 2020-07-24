//
//  MBUrgerKeychain.swift
//  MBurgerSwift
//
//  Created by Lorenzo Oliveto on 23/07/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit
import Security

internal class MBurgerTokenKeychain: NSObject {
    private static var service: String {
        return "com.mumble.mburger.service"
    }
    
    private static var account: String {
        return "com.mumble.mburger.account"
    }

    @discardableResult
    static func saveToken(_ token: String) -> Bool {
        let query = MBurgerTokenQuery(service: service, account: account, password: token)
        return query.save()
    }
    
    static func token() -> String? {
        let query = MBurgerTokenQuery(service: service, account: account)
        _ = query.fetch()
        return query.password
    }
    
    @discardableResult
    static func removeToken() -> Bool {
        let query = MBurgerTokenQuery(service: service, account: account)
        return query.deleteItem()
    }
}

private class MBurgerTokenQuery {
    var account: String?
    var service: String?
    var accessGroup: String?
    var passwordData: Data?
    var password: String? {
        if let passwordData = passwordData {
            return String(data: passwordData, encoding: .utf8)
        }
        return nil
    }
    
    init(service: String?, account: String?, password: String? = nil) {
        self.service = service
        self.account = account
        if let password = password {
            self.passwordData = password.data(using: .utf8)
        }
    }
    
    func save() -> Bool {
        guard service != nil, account != nil, passwordData != nil else {
            print("Keychain failed, service, account or password is nil")
            return false
        }
        
        var status: OSStatus?

        let searchQuery = self.query()
        status = SecItemCopyMatching(searchQuery as CFDictionary, nil)
        if status == errSecSuccess { //item already exists, update it!
            var query = [String: Any]()
            query[kSecValueData as String] = passwordData
            status = SecItemUpdate(searchQuery as CFDictionary, query as CFDictionary)
        } else if status == errSecItemNotFound {
            var query = self.query()
            query[kSecValueData as String] = passwordData
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        return status == errSecSuccess
    }
    
    func deleteItem() -> Bool {
        guard service != nil, account != nil else {
            print("Keychain failed, service or account is nil")
            return false
        }
        
        var status: OSStatus?
        let query = self.query()
        status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
        
    func fetch() -> Bool {
        guard service != nil, account != nil else {
            print("Keychain failed, service or account is nil")
            return false
        }

        var query = self.query()
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne as String
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status != errSecSuccess {
            return false
        }
        self.passwordData = result as? Data
        return true
    }
    
    private func query() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary[kSecClass as String] = kSecClassGenericPassword as String
        
        if let service = service {
            dictionary[kSecAttrService as String] = service
        }
        
        if let account = account {
            dictionary[kSecAttrAccount as String] = account
        }

        if let accessGroup = accessGroup {
            dictionary[kSecAttrAccessGroup as String] = accessGroup
        }
        
        return dictionary
    }
}
