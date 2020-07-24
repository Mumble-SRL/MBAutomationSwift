//
//  MBApiManager.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumbble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation
import UIKit
import MBNetworkingSwift

/// Error returned by the MBurger apis
struct MBurgerError: LocalizedError {
    public var errorDescription: String? { return message }
    public var failureReason: String? { return message }
    public var recoverySuggestion: String? { return nil }
    public var helpAnchor: String? { return nil }

    /// Status code of the error
    public var statusCode: Int
    
    /// Message of the error
    private var message: String?

    /// Initializes and returns a new error
    init(statusCode: Int, message: String?) {
        self.statusCode = statusCode
        self.message = message
    }
}

/// This class is responsible to make all the networking requests to the MBurger Api, MBManager, MBClient and MBAdmin are built above this class.
public final class MBApiManager {
    private init() {}
    
    /// Calls the api to the MBurger endpoint with the parameters specified. At the end of the network call it will be called the success block or the failure block.
    /// - Parameters:
    ///   - token: The api token used to call the MBurger Api.
    ///   - locale: The locale passed to the api call.
    ///   - apiName: The name of the api to call.
    ///   - method: The `HTTPMethod` of the request, `.get` by default.
    ///   - headers: The headers for the request, `nil` by default.
    ///   - parameters: The parameters for the request, `nil` by default, its an alias for `[String: Any]`.
    ///   - development: If it's in development mode, `false` by default.
    ///   - encoding: An object that implements `ParameterEncoder`, used to encode the parameters
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - response: The `[String: Any]` representation of the response of the call.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public class func request(withToken token: String,
                              locale: String,
                              apiName: String,
                              method: HTTPMethod,
                              headers: [HTTPHeader]? = nil,
                              parameters: Parameters? = nil,
                              development: Bool = false,
                              encoding: ParameterEncoder = JSONParameterEncoder.default,
                              success: @escaping (_ response: [String: Any]) -> Void,
                              failure: @escaping (_ error: Error) -> Void) {
        let urlString = constructUrl(withApiname: apiName, developmentMode: development)
        
        var heads = headers ?? []
        addRequiredHeaders(token, headers: &heads)
        
        var completeParameters = parameters ?? [:]
        addRequiredParameters(&completeParameters, locale: locale)
        
        MBNetworking.request(withUrl: urlString, method: method, headers: heads, parameters: completeParameters, encoding: encoding) { (response) in
            parse(response: response, success: success, failure: failure)
        }
    }
    
    /// Calls the api to the MBurger endpoint with the parameters specified. At the end of the network call it will be called the success block or the failure block. This is used to upload elements to MBurger.
    /// - Parameters:
    ///   - token: The api token used to call the MBurger Api.
    ///   - locale: The locale passed to the api call.
    ///   - apiName: The name of the api to call.
    ///   - method: The `HTTPMethod` of the request, `.get` by default.
    ///   - headers: The headers for the request, `nil` by default.
    ///   - multipartParameters: An array of `MBMultipartForm` passed as form data with the request.
    ///   - development: If it's in development mode, `false` by default.
    ///   - completion: A completion block that will be called when the request finishes, successfully or with error, the block will have a parameter (the `MBMultipartResponse`) and will return no value.
    public class func upload(withToken token: String,
                             locale: String,
                             apiName: String,
                             method: HTTPMethod,
                             headers: [HTTPHeader]? = nil,
                             multipartParameters: [MBMultipartForm],
                             development: Bool = false,
                             completion: @escaping(MBMultipartResponse) -> Void) {
        precondition(!token.isEmpty, "MBurger token not set")
        
        let urlString = constructUrl(withApiname: apiName, developmentMode: development)
        
        var completeHeaders = headers ?? []
        addRequiredHeaders(token, headers: &completeHeaders)
        
        MBNetworking.upload(toUrl: urlString, headers: completeHeaders, parameters: multipartParameters, completion: completion)
    }
    
    class private func apiBaseUrl(_ isInDevelopment: Bool) -> String {
        return isInDevelopment ? "https://dev.mburger.cloud/api" : "https://mburger.cloud/api"
    }
    
    class private func constructUrl(withApiname name: String, developmentMode: Bool) -> String {
        var baseUrl = apiBaseUrl(developmentMode)
        if !baseUrl.hasSuffix("/") {
            baseUrl += "/"
        }
        return baseUrl + name
    }
    
    class private func addRequiredHeaders(_ token: String, headers: inout [HTTPHeader]) {
        var requiredHeaders = [HTTPHeader(field: "Accept", value: "application/json"),
         HTTPHeader(field: "X-MBurger-Token", value: token),
         HTTPHeader(field: "X-MBurger-Version", value: "3")
        ]
        if let authorizationToken = MBAuth.authToken, !authorizationToken.isEmpty {
            requiredHeaders.append(HTTPHeader(field: "Authorization", value: "Bearer \(authorizationToken)"))
        }
        headers.append(contentsOf: requiredHeaders)
    }
    
    class private func addRequiredParameters(_ params: inout Parameters, locale: String) {
        let uuidString = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let defaultParameters: Parameters = ["locale": locale, "os": "ios", "device_id": uuidString]
        params.merge(defaultParameters, uniquingKeysWith: { $1 })
    }
    
    class private func parse(response: MBResponse<Any>,
                             success: @escaping (_ response: [String: Any]) -> Void,
                             failure: @escaping (_ error: Error) -> Void) {
        guard response.error == nil else {
            failure(MBError.customError(reason: response.error?.localizedDescription ?? ""))
            return
        }
        
        switch response.result {
        case .success(let json):
            guard let unwrappedJson = json as? [String: Any] else {
                failure(MBError.customError(reason: "couldn't unwrap"))
                return
            }
            
            MBAuth.saveNewTokenIfPresent(inResponse: response.response)
            
            let statusCode = unwrappedJson["status_code"] as? Int ?? 0
            if statusCode == 0 {
                DispatchQueue.main.async {
                    if let body = unwrappedJson["body"] as? [String: Any] {
                        success(body)
                    } else {
                        success(unwrappedJson)
                    }
                }
            } else {
                let message = unwrappedJson["message"] as? String
                failure(MBurgerError(statusCode: statusCode, message: message))
            }
        case .error(let error):
            var failureError = error
            if let error = error as? MBError {
                switch error {
                case .validationFailure(_, let data):
                    if let data = data,
                        let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let statusCode = dictionary["status_code"] as? Int ?? 0
                        let message = dictionary["message"] as? String
                        failureError = MBurgerError(statusCode: statusCode, message: message)
                    }
                default:
                    break
                }
            }
            DispatchQueue.main.async {
                failure(failureError)
            }
        }
    }
}
