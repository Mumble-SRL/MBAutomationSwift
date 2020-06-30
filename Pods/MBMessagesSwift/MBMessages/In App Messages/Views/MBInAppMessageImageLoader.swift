//
//  MBInAppMessageImageLoader.swift
//  MBInAppMessage
//
//  Created by Lorenzo Oliveto on 17/03/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

class MBInAppMessageImageLoader: UIView {

    static func loadImage(url: String?, completion: @escaping (UIImage?) -> Void) {
        guard let urlString = url else {
            completion(nil)
            return
        }
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        guard let fileUrl = fileUrlForUrl(url: url) else {
            completion(nil)
            return
        }
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            if let image = UIImage(contentsOfFile: fileUrl.path) {
                completion(image)
                return
            }
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completion(nil)
                    return
            }
            DispatchQueue.main.async {
                try? data.write(to: fileUrl)
                completion(image)
            }
        }.resume()
    }
    
    static private func fileUrlForUrl(url: URL) -> URL? {
        let fileName = url.lastPathComponent
        guard let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let completeUrl = cacheUrl.appendingPathComponent(fileName)
        return completeUrl
    }
}
