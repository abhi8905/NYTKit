//
//  CacheEntry.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Foundation

public struct CacheEntry<T: Codable & Sendable>: Codable, Sendable {
    public let creationDate: Date
    public let value: T

    public init(creationDate: Date, value: T) {
        self.creationDate = creationDate
        self.value = value
    }
}
