//
//  MBMedia.swift
//  MBurgerSwift
//
//  Created by Alessandro Viviani on 26/09/2019.
//  Copyright © 2019 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import Foundation

/// This class represents a media.
public class MBMedia: Codable, Equatable {
    /// The id of the media.
    public let mediaId: Int
    
    /// The uuid of the media
    public let uuid: UUID
    
    /// The url of the media.
    public let url: URL
    
    /// The MIME type of the media.
    public let mimeType: String
    
    /// The size of the media in byte.
    public let size: Int
    
    /// The file name of this media
    public let fileName: String?
    
    /// Initializes a media with an id, the URL, MIME type and the size.
    /// - Parameters:
    ///   - mediaId: The `id` of the media.
    ///   - uuid: The `uuid` of the media
    ///   - url: The `URL` of the media.
    ///   - mimeType: The `MIME` type of the element.
    ///   - size: The `size` of the media.
    ///   - fileName: The `fileName` of the media.
    init(mediaId: Int,
         uuid: UUID,
         url: URL,
         mimeType: String,
         size: Int,
         fileName: String?) {
        self.mediaId = mediaId
        self.uuid = uuid
        self.url = url
        self.mimeType = mimeType
        self.size = size
        self.fileName = fileName
    }
    
    /// Convenience initializer for a media with the dictionary returned by the api.
    /// - Parameters:
    ///   - dictionary: The `Dictionary` returned from the APIs reponse
    public convenience init(dictionary: [String: Any]) {
        let mediaId = dictionary["id"] as? Int ?? 0
        let uuidString = dictionary["uuid"] as? String ?? MBMedia.invalidUUIDString()
        let uuid = UUID(uuidString: uuidString) ?? UUID()
        let mimeType = dictionary["mime_type"] as? String ?? ""
        let size = dictionary["size"] as? Int ?? 0
        let imageUrlString = dictionary["url"] as? String ?? ""
        let url = URL(string: imageUrlString)!
        let fileName = dictionary["file_name"] as? String

        self.init(mediaId: mediaId,
                  uuid: uuid,
                  url: url,
                  mimeType: mimeType,
                  size: size,
                  fileName: fileName)
    }
    
    /// An invalid UUID string
    private static func invalidUUIDString() -> String {
        return "00000000-0000-0000-0000-000000000000"
    }
    
    // MARK: - Equatable protocol
    public static func == (lhs: MBMedia, rhs: MBMedia) -> Bool {
        return lhs.mediaId == rhs.mediaId
    }
    
    // MARK: - Codable protocol
    enum CodingKeys: String, CodingKey {
        case mediaId
        case uuid
        case url
        case mimeType
        case size
        case fileName
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        mediaId = try container.decode(Int.self, forKey: .mediaId)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        url = try container.decode(URL.self, forKey: .url)
        mimeType = try container.decode(String.self, forKey: .mimeType)
        size = try container.decode(Int.self, forKey: .size)
        fileName = try? container.decode(String.self, forKey: .fileName)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(mediaId, forKey: .mediaId)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(url, forKey: .url)
        try container.encode(mimeType, forKey: .mimeType)
        try container.encode(size, forKey: .size)
        try container.encode(fileName, forKey: .fileName)
    }
}
