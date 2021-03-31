//
//  MBClient.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation
import MBNetworkingSwift

/// The main client of the SDK, this is your entry point for all the calls you do with MBurger.
/// All the api calls have two blocks as parameters called when the api completes, one (Success) for the succes case and one for the failure (Failure). These blocks are pushed in the main thread by the SDK.
/// When the return of the api is an array it's returned also a `MBPaginationInfo` object with the information about the pagination (total number of elements and the range of the elements returned)

public final class MBClient {
    
    // MARK: - Project
    
    /// Retrieve the informations about the project.
    /// - Parameters:
    ///   - includingContracts: If `true` contracts are included in the project, `false` by default.
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - project: the `MBProject` returned by the api.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func getProject(withContracts includingContracts: Bool = false,
                                  success: @escaping (_ project: MBProject) -> Void,
                                  failure: @escaping (_ error: Error) -> Void) {
        var parameters: Parameters? = [:]
        
        if includingContracts {
            parameters?["include"] = "contracts"
        }
        
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "project",
                             method: .get,
                             parameters: parameters,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                success(MBProject(dictionary: response))
        }, failure: { error in
            failure(error)
        })
    }
    
    // MARK: - Blocks
    
    /// Retrieve the blocks of the project.
    /// - Parameters:
    ///   - parameters: An optional array of `MBParameter` used to sort, `nil` by default.
    ///   - sections: If `true` the information of the sections in the blocks are included in the response, `false` by default.
    ///   - elements: If `true` of the elements in the sections of the blocks are included in the response, `false` by default.
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes two arguments.
    ///   - blocks: An array of `MBBlock` returned by the api.
    ///   - paginationInfo: The informations about pagination.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    
    public static func getBlocks(withParameters parameters: [MBParameter]? = nil,
                                 includingSections sections: Bool = false,
                                 includeElements elements: Bool = false,
                                 success: @escaping (_ blocks: [MBBlock], _ paginationInfo: MBPaginationInfo) -> Void,
                                 failure: @escaping (_ error: Error) -> Void) {
        var apiParameters: Parameters = [:]
        
        if sections {
            apiParameters["include"] = elements ? "sections.elements" : "sections"
        }

        if let parameters = parameters {
            for parameter in parameters {
                apiParameters.merge(parameter.parameterRepresentation(), uniquingKeysWith: {$1})
            }
        }
        
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: "blocks",
                             method: .get,
                             parameters: apiParameters,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                let paginationInfo = MBPaginationInfo(dictionary: response["meta"] as? [String: Any] ?? [:])
                                
                                var blocks = [MBBlock]()
                                if let items = response["items"] as? [[String: Any]] {
                                    blocks = []
                                    blocks = items.map { MBBlock($0) }
                                }
                                success(blocks, paginationInfo)
        }, failure: { error in
            failure(error)
        })
    }
    
    /// Retrieve the block of the project with the specified id.
    /// - Parameters:
    ///   - blockId: The `id` of the block.
    ///   - parameters: An optional array of `MBParameter` used to sort, `nil` by default.
    ///   - sections: If `true` the information of the sections in the blocks are included in the response, `false` by default.
    ///   - elements: If `true` of the elements in the sections of the blocks are included in the response, `false` by default.
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - block: The `MBBlock` returned by the api.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    
    public static func getBlock(withId blockId: Int,
                                parameters: [MBParameter]? = nil,
                                includeSections sections: Bool = false,
                                includeElements elements: Bool = false,
                                success: @escaping (_ block: MBBlock) -> Void,
                                failure: @escaping (_ error: Error) -> Void) {
        var apiParameters: Parameters = [:]
        
        if sections {
            apiParameters["include"] = elements ? "sections.elements" : "sections"
        }

        if let parameters = parameters {
            for parameter in parameters {
                apiParameters.merge(parameter.parameterRepresentation(), uniquingKeysWith: {$1})
            }
        }
        
        let apiName = String(format: "blocks/%d", blockId)
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: apiName,
                             method: .get,
                             parameters: apiParameters,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                let block = MBBlock(response)
                                success(block)
        }, failure: { error in
            failure(error)
        })
    }
    
    // MARK: - Sections

    /// Retrieve the sections of the block with the specified id.
    /// - Parameters:
    ///   - blockId: The `id` of the block.
    ///   - parameters: An optional array of `MBParameter`, `nil` by default.
    ///   - elements: If `true` the informations about the elements in the sections of the blocks are included in the response, `false` by default.
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes two arguments.
    ///   - sections: An array of `MBSection` returned by the api.
    ///   - paginationInfo: The informations about pagination.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    
    public static func getSections(ofBlock blockId: Int,
                                   parameters: [MBParameter]? = nil,
                                   elements: Bool = false,
                                   success: @escaping (_ sections: [MBSection], _ paginationInfo: MBPaginationInfo) -> Void,
                                   failure: @escaping (_ error: Error) -> Void) {
        var apiParameters: Parameters = [:]
        
        if elements {
            apiParameters["include"] = "elements"
        }
        
        if let parameters = parameters {
            for parameter in parameters {
                apiParameters.merge(parameter.parameterRepresentation(), uniquingKeysWith: {$1})
            }
        }
        
        let apiName = String(format: "blocks/%d/sections", blockId)
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: apiName,
                             method: .get,
                             parameters: apiParameters,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                let paginationInfo = MBPaginationInfo(dictionary: response["meta"] as? [String: Any] ?? [:])
                                
                                var sections: [MBSection] = []
                                if let items = response["items"] as? [[String: Any]] {
                                    sections = items.map { MBSection($0) }
                                }
                                success(sections, paginationInfo)
        }, failure: { error in
            failure(error)
        })
    }
    
    /// Retrieve the section with the specified id.
    /// - Parameters:
    ///   - sectionId: The `id` of the section.
    ///   - parameters: An optional array of `MBParameter`, `nil` by default.
    ///   - elements: If `true` the informations about the elements in the sections of the blocks are included in the response, `false` by default.
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - section: A `MBSection` returned by the api.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    
    public static func getSection(withId sectionId: Int,
                                  parameters: [MBParameter]? = nil,
                                  elements: Bool = false,
                                  success: @escaping (_ section: MBSection) -> Void,
                                  failure: @escaping (_ error: Error) -> Void) {
        var apiParameters: Parameters = [:]
        
        if elements {
            apiParameters["include"] = "elements"
        }
        
        if let parameters = parameters {
            for parameter in parameters {
                apiParameters.merge(parameter.parameterRepresentation(), uniquingKeysWith: {$1})
            }
        }

        let apiName = String(format: "sections/%d", sectionId)
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: apiName,
                             method: .get,
                             parameters: apiParameters,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                let section = MBSection(response)
                                success(section)
        }, failure: { error in
            failure(error)
        })
    }
    
    /// Retrieve the section with the specified slug.
    /// - Parameters:
    ///   - slug: The `slug` of the section.
    ///   - parameters: An optional array of `MBParameter`, `nil` by default.
    ///   - elements: If `true` the informations about the elements in the sections of the blocks are included in the response, `false` by default.
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - section: A `MBSection` returned by the api.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    
    public static func getSection(withSlug slug: String,
                                  parameters: [MBParameter]? = nil,
                                  elements: Bool = false,
                                  success: @escaping (_ section: MBSection) -> Void,
                                  failure: @escaping (_ error: Error) -> Void) {
        var apiParameters: Parameters = [:]
        
        apiParameters["use_slug"] = "true"
        if elements {
            apiParameters["include"] = "elements"
        }
        
        if let parameters = parameters {
            for parameter in parameters {
                apiParameters.merge(parameter.parameterRepresentation(), uniquingKeysWith: {$1})
            }
        }

        let apiName = String(format: "sections/%@", slug)
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: apiName,
                             method: .get,
                             parameters: apiParameters,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                let section = MBSection(response)
                                success(section)
        }, failure: { error in
            failure(error)
        })
    }

    // MARK: - Elements

    /// Retrieve the elements of the section with the specified id.
    /// - Parameters:
    ///   - sectionId: The `id` of the section.
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - elements: A dictionary of elements of the sections returned by the api (the dictionary returned is like the `[String: MBElement]`).
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func getElements(ofSection sectionId: Int,
                                   success: @escaping (_ elements: [String: MBElement]) -> Void,
                                   failure: @escaping (_ error: Error) -> Void) {
        let apiName = String(format: "sections/%d/elements", sectionId)
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: apiName,
                             method: .get,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                var elements = [String: MBElement]()
                                if let items = response["items"] as? [String: Any] {
                                    for key in items.keys {
                                        if let elementDictionary = items[key] as? [String: Any] {
                                            elements[key] = MBElementFactory.element(forDictionary: elementDictionary)
                                        }
                                    }
                                }
                                success(elements)
        }, failure: { error in
            failure(error)
        })
    }
    
    // MARK: - Media
    
    /// Retrieve the media of the project with the specified id.
    /// - Parameters:
    ///   - id: The `id` of the media.
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - media: The media requested.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func getMedia(withId id: Int,
                                success: @escaping (_ media: MBMedia) -> Void,
                                failure: @escaping (_ error: Error) -> Void) {
        let apiName = String(format: "media/%d", id)
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: apiName,
                             method: .get,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                let media = MBMedia(dictionary: response)
                                success(media)
        }, failure: { error in
            failure(error)
        })
    }
    
    /// Retrieve all the media of the project.
    /// - Parameters:
    ///   - success: A block that will be called when the request ends successfully. This block has no return value and takes one argument.
    ///   - media: All the media that are present in the project.
    ///   - failure: A block that will be called when the request ends incorrectly. This block has no return value and takes one argument.
    ///   - error: The error describing the error that occurred.
    public static func getAllMedia(success: @escaping (_ media: [MBMedia]) -> Void,
                                   failure: @escaping (_ error: Error) -> Void) {
        let apiName = "media"
        MBApiManager.request(withToken: MBManager.shared.apiToken,
                             locale: MBManager.shared.localeString,
                             apiName: apiName,
                             method: .get,
                             development: MBManager.shared.development,
                             encoding: URLParameterEncoder.queryItems,
                             success: { response in
                                guard let body = response["body"] as? [[String: Any]] else {
                                    success([])
                                    return
                                }
                                let media = body.map({ MBMedia(dictionary: $0) })
                                success(media)
        }, failure: { error in
            failure(error)
        })

    }
}
