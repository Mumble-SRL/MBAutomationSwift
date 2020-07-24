//
//  MBFile.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a file.
public class MBFile: Codable, Equatable {
    /// The id of the file.
    public let fileId: Int
    
    /// The url of the media.
    public let url: URL
    
    /// The MIME type of the media.
    public let mimeType: String
    
    /// The size of the media in byte.
    public let size: Int
    
    /// Initializes a file with an id, the URL, MIME type and the size.
    /// - Parameters:
    ///   - fileId: The `id` of the file.
    ///   - url: The `URL` of the file.
    ///   - mimeType: The `MIME` type of the element.
    ///   - size: The `size` of the image.
    init(fileId: Int, url: URL, mimeType: String, size: Int) {
        self.fileId = fileId
        self.url = url
        self.mimeType = mimeType
        self.size = size
    }
    
    /// Convenience initializer for a file with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    convenience init(dictionary: [String: Any]) {
        let fileId = dictionary["id"] as? Int ?? 0
        let mimeType = dictionary["mime_type"] as? String ?? ""
        let size = dictionary["size"] as? Int ?? 0
        let imageUrlString = dictionary["url"] as? String ?? ""
        let url = URL(string: imageUrlString)!
        
        self.init(fileId: fileId, url: url, mimeType: mimeType, size: size)
    }
    
    // MARK: - Equatable protocol
    public static func == (lhs: MBFile, rhs: MBFile) -> Bool {
        return lhs.fileId == rhs.fileId
    }
    
    // MARK: - Codable protocol
    enum CodingKeys: String, CodingKey {
        case fileId
        case url
        case mimeType
        case size
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        fileId = try container.decode(Int.self, forKey: .fileId)
        url = try container.decode(URL.self, forKey: .url)
        mimeType = try container.decode(String.self, forKey: .mimeType)
        size = try container.decode(Int.self, forKey: .size)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(size, forKey: .size)
        try container.encode(fileId, forKey: .fileId)
        try container.encode(mimeType, forKey: .mimeType)
        try container.encode(url, forKey: .url)
    }
}
