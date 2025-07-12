//
//  APIEnvironment.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Foundation

public protocol APIEnvironment {
    var scheme: String { get }
    var host: String { get }
}

/// A note on environments:
/// Currently, both the Development and Production environments point to the same live NYT API server,
/// as a dedicated development or staging server is not available for this public API.
/// This structure is in place to support future needs if different environments become available.

public struct DevelopmentEnvironment: APIEnvironment {
    public var scheme: String { "https" }
    public var host: String { "api.nytimes.com" }
    
    public init() {}
}

public struct ProductionEnvironment: APIEnvironment {
    public var scheme: String { "https" }
    public var host: String { "api.nytimes.com" }
    
    public init() {}
}
