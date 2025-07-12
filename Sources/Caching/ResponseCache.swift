//
//  ResponseCache.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//


import Foundation

public protocol ResponseCacheProtocol: Sendable {
    func set<T: Codable & Sendable>(_ value: T, forKey key: String) async
    func get<T: Codable & Sendable>(forKey key: String) async -> CacheEntry<T>?
}

public actor ResponseCache: ResponseCacheProtocol {
    // MARK: - Singleton
    public static let shared: ResponseCacheProtocol = ResponseCache()

    // MARK: - Internal Cache
    private let cache = NSCache<NSString, NSData>()

    // MARK: - Init
    private init() {
        cache.name = "NYTimesApp.ResponseCache"
    }

    // MARK: - ResponseCacheProtocol
    public func set<T: Codable & Sendable>(_ value: T, forKey key: String) async {
        do {
            let entry = CacheEntry(creationDate: Date(), value: value)
            let data = try JSONEncoder().encode(entry)
            cache.setObject(data as NSData, forKey: key as NSString)
        } catch {
            print("Failed to encode response for caching: \(error)")
        }
    }

    public func get<T: Codable & Sendable>(forKey key: String) async -> CacheEntry<T>? {
        guard let data = cache.object(forKey: key as NSString) as Data? else {
            return nil
        }
        do {
            return try JSONDecoder().decode(CacheEntry<T>.self, from: data)
        } catch {
            print("Failed to decode cached response: \(error)")
            return nil
        }
    }
}
