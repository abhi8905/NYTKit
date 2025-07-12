//
//  ImageCache.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//


import UIKit

public protocol ImageCacheProtocol: Sendable {
    func set(_ image: UIImage, forKey key: String) async
    func get(forKey key: String) async -> UIImage?
    func clear() async
}

public actor ImageCache: ImageCacheProtocol {
    public static let shared: ImageCacheProtocol = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.name = "NYTimesApp.ImageCache"
    }

    public func set(_ image: UIImage, forKey key: String) async {
        cache.setObject(image, forKey: key as NSString)
    }

    public func get(forKey key: String) async -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    public func clear() async {
        cache.removeAllObjects()
    }
}
