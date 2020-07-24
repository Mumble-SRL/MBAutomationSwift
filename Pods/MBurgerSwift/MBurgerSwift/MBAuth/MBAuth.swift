//
//  MBAuth.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 27/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation
import UIKit
import MBNetworkingSwift

/// The type of social tokens supported by MBurger
public enum MBAuthSocialTokenType: Int {
    /// A Facebook token
    case facebook = 0
    /// A Google token
    case google = 1
    /// A Apple sign in token
    case apple = 2
}

/// Manages the authentication of the user.
public struct MBAuth {
    static var userIsLoggedInUserDefaults: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "com.mumble.mburger.auth.userLoggedIn")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "com.mumble.mburger.auth.userLoggedIn")
        }
    }
    
    /// The access token that represents the user, if an user has been authenticated correctly.
    public static var authToken: String? {
        if userIsLoggedInUserDefaults {
            guard let token = mbAuthToken else {
                let tokenFromKeychain = MBurgerTokenKeychain.token()
                mbAuthToken = tokenFromKeychain
                return tokenFromKeychain
            }
            return token
        }
        return nil
    }
    
    fileprivate static var mbAuthToken: String?
    
    /// Returns TRUE if a user is authenticated. This funcion check if the access token saved in the keychain is non-nil and different from an empty string.
    public static var userIsLoggedIn: Bool {
        let token = authToken ?? ""
        return !token.isEmpty && userIsLoggedInUserDefaults
    }
    
    static func save(accessToken token: String) {
        if !token.isEmpty && userIsLoggedInUserDefaults {
            self.mbAuthToken = token
            MBurgerTokenKeychain.saveToken(token)
        }
    }
    
    // MARK: - Register
    
    /// Register a user in MBurger
    /// - Parameters:
    ///   - name: The `nameString` of the user
    ///   - surname: The `surnameString` of the user
    ///   - email: The `emailString` of the user
    ///   - password: The `passwordString` entered by the user
    ///   - phone: The `phoneString` of the user, `nil` by default
    ///   - image: The `UIImage` of the user, `nil` by default
    ///   - contracts: The `[MBAuthContractAcceptanceParameter]` accepted by the user, `nil` by default
    ///   - data: The `Dictionary` of additional data of the user to save, `nil` by default
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes no argument.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func registerUser(withName name: String,
                                    surname: String,
                                    email: String,
                                    password: String,
                                    phone: String?,
                                    image: UIImage?,
                                    contracts: [MBAuthContractAcceptanceParameter]? = nil,
                                    data: [String: Any]?,
                                    success: @escaping () -> Void,
                                    failure: @escaping (_ error: Error) -> Void) {
        var apiParameters: Parameters = ["name": name, "surname": surname, "email": email, "password": password]
        
        if let phone = phone {
            apiParameters["phone"] = phone
        }
        
        if let image = image {
            let imageData = image.jpegData(compressionQuality: 1.0)
            apiParameters["image"] = imageData?.base64EncodedString()
        }
        
        if let contracts = contracts {
            apiParameters["contracts"] = contracts.JSONtoString()
        }
        
        if let unwrappedData = data {
            apiParameters["data"] = unwrappedData.JSONtoString()
        }
        
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "register",
                             method: .post,
                             parameters: apiParameters,
                             development: MBManager.shared.development,
                             success: { _ in
                                success()
        }, failure: { error in
            failure(error)
        })
    }
    
    // MARK: - Authenticate
    
    /// Authenticates a user giving the email and password
    /// - Parameters:
    ///   - email: The `emailString` of the user
    ///   - password: The `passwordString` of the user
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - accessToken: The access token will be saved in the Keychain and will be used in all the subsequent calls to the MBurger apis.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func authenticateUser(withEmail email: String,
                                        password: String,
                                        success: @escaping (_ accessToken: String) -> Void,
                                        failure: @escaping (_ error: Error) -> Void) {
        let parameters: Parameters = ["mode": "email", "email": email, "password": password]
        authenticateUser(withParameters: parameters, success: success, failure: failure)
    }
    
    /// Authenticates a user using the social token
    /// - Parameters:
    ///   - token: The `token` to authenticate the user
    ///   - tokenType: The `tokenType` (.facebook, .google, .apple)
    ///   - name: The `nameString` of the user
    ///   - surname: The `surnameString` of the user
    ///   - contracts: The `[MBAuthContractAcceptanceParameter]` accepted by the user, `nil` by default
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - accessToken: The access token will be saved in the Keychain and will be used in all the subsequent calls to the MBurger apis.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func authenticateUser(withSocialToken token: String,
                                        tokenType: MBAuthSocialTokenType,
                                        name: String? = nil,
                                        surname: String? = nil,
                                        contracts: [MBAuthContractAcceptanceParameter]?,
                                        success: @escaping (_ accessToken: String) -> Void,
                                        failure: @escaping (_ error: Error) -> Void) {
        var apiParameters = Parameters()
        
        if let contracts = contracts, contracts.count > 0 {
            apiParameters["contracts"] = contracts.JSONtoString()
        }
        
        if tokenType == .facebook {
            apiParameters["mode"] = "facebook"
            apiParameters["facebook_token"] = token
        } else if tokenType == .google {
            apiParameters["mode"] = "google"
            apiParameters["google_token"] = token
        } else if tokenType == .apple {
            apiParameters["mode"] = "apple"
            apiParameters["apple_token"] = token
        }
        
        if let name = name {
            apiParameters["name"] = name
        }
        if let surname = surname {
            apiParameters["surname"] = surname
        }

        authenticateUser(withParameters: apiParameters, success: success, failure: failure)
    }
    
    fileprivate static func authenticateUser(withParameters parameters: Parameters,
                                             success: @escaping (_ accessToken: String) -> Void,
                                             failure: @escaping (Error) -> Void) {
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "authenticate",
                             method: .post,
                             parameters: parameters,
                             development: MBManager.shared.development,
                             success: { response in
                                let accessToken = response["access_token"] as? String ?? ""
                                userIsLoggedInUserDefaults = true
                                save(accessToken: accessToken)
                                success(accessToken)
        }, failure: { error in
            failure(error)
        })
    }
    
    // MARK: - Logout User
    
    /// Logs out the current user
    /// - Parameters:
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes no argument.
    ///    - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func logoutCurrentUser(_ success: @escaping () -> Void,
                                         failure: @escaping (_ error: Error) -> Void) {
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "logout",
                             method: .post,
                             development: MBManager.shared.development,
                             success: { _ in
                                logoutCurrentUser()
                                success()
        }, failure: { error in
            failure(error)
        })
    }
    
    /// Change the password for the current authenticated user
    /// - Parameters:
    ///   - email: The `emailString` of the user
    ///   - password: The `passwordString` of the user
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes no argument.
    ///    - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func changePasswordForCurrentUser(withOldPassword password: String,
                                                    newPassword: String,
                                                    success: @escaping () -> Void,
                                                    failure: @escaping (_ error: Error) -> Void) {
        let parameters: Parameters = ["old_password": password, "new_password": newPassword]
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "change-password",
                             method: .post,
                             parameters: parameters,
                             development: MBManager.shared.development,
                             success: { _ in
                                success()
        }, failure: { error in
            failure(error)
        })
    }
    
    /// Call this api if the user wants to reset its password. A mail will be sended to the user with a new password if a user with the given email is found in MBurger.
    /// - Parameters:
    ///   - email: The `emailString` of the user
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes no argument.
    ///    - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func forgotPassword(withEmail email: String,
                                      success: @escaping () -> Void,
                                      failure: @escaping (_ error: Error) -> Void) {
        let parameters: Parameters = ["email": email]
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "forgot-password",
                             method: .post,
                             parameters: parameters,
                             development: MBManager.shared.development,
                             success: { _ in
                                success()
        }, failure: { error in
            failure(error)
        })
    }
    
    /// Retrieves the profile informations of the current authenticated user.
    /// - Parameters:
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - user:  The `MBUser` representing the logged user.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func getUserProfile(success: @escaping (_ user: MBUser) -> Void,
                                      failure: @escaping (_ error: Error) -> Void) {
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "profile",
                             method: .get,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                var user = MBUser(dictionary: response)
                                handlePlugins(response, user: &user)
                                success(user)
        }, failure: { error in
            failure(error)
        })
    }
   
    /// Updates the profile informations of the current authenticated user.
    /// - Parameters:
    ///   - name: The `nameString` of the user
    ///   - surname: The `surnameString` of the user
    ///   - phone: The `phoneString` of the user, `nil` by default
    ///   - image: The `UIImage` of the user, `nil` by default
    ///   - contracts: The `[MBAuthContractAcceptanceParameter]` accepted by the user, `nil` by default
    ///   - data: The `Dictionary` of additional data of the user to save, `nil` by default
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - user: The `MBUser` representing the logged user.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func updateProfile(withName name: String,
                                     surname: String,
                                     phone: String?,
                                     image: UIImage?,
                                     contracts: [MBAuthContractAcceptanceParameter]? = nil,
                                     data: [String: Any]?,
                                     success: @escaping (_ user: MBUser) -> Void,
                                     failure: @escaping (_ error: Error) -> Void) {
        var parameters: Parameters = ["name": name, "surname": surname]
        
        if let phone = phone {
            parameters["phone"] = phone
        }
        
        if let image = image {
            let imageData = image.jpegData(compressionQuality: 1.0)
            parameters["image"] = imageData?.base64EncodedString()
        }
        
        if let contracts = contracts {
            parameters["contracts"] = contracts.JSONtoString()
        }
        
        if let unwrappedData = data {
            parameters["data"] = unwrappedData.JSONtoString()
        }
        
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "profile/update",
                             method: .post,
                             parameters: parameters,
                             development: MBManager.shared.development,
                             success: { response in
                                let user = MBUser(dictionary: response)
                                success(user)
        }, failure: { error in
            failure(error)
        })
    }
    
    /// Deletes the current authenticated user. It will call the `logoutCurrentUser` if the deletion is succesful.
    /// - Parameters:
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes no argument.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func deleteCurrentUser(success: @escaping () -> Void,
                                         failure: @escaping (_ error: Error) -> Void) {
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "profile/delete",
                             method: .delete,
                             development: MBManager.shared.development,
                             success: { _ in
                                logoutCurrentUser()
                                success()
        }, failure: { error in
            failure(error)
        })
    }
    
    static func logoutCurrentUser() {
        mbAuthToken = nil
        userIsLoggedInUserDefaults = false
        MBurgerTokenKeychain.removeToken()
    }
    
    static func saveNewTokenIfPresent(inResponse response: HTTPURLResponse?) {
        if userIsLoggedIn {
            guard let headers = response?.allHeaderFields else { return }
            if let token = headers["Authorization"] as? String, !token.isEmpty {
                let accessToken = "Bearer ".appending(token)
                save(accessToken: accessToken)
            }
        }
    }
    
    static func handlePlugins(_ resp: [String: Any], user: inout MBUser) {
        let plugins = MBManager.shared.plugins
        if plugins.count != 0 {
            var pluginDictionary = [String: Any]()
            for plugin in plugins {
                guard let userKey = plugin.userKey else {
                    continue
                }
                if let objcForResp = plugin.object(forUserResponse: resp) {
                    pluginDictionary[userKey] = objcForResp
                }
            }
            user.pluginsObjects = pluginDictionary
        }
    }
}

extension Collection {
    /// Returns a String of the serialized data of the collection
    public func JSONtoString() -> String {
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: serializedData, encoding: .utf8) ?? ""
        } catch let error {
            print(error.localizedDescription)
            return ""
        }
    }
}
