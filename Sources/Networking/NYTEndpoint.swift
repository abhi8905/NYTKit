//
//  NYTEndpoint.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//


import Foundation

enum NYTEndpoint: Endpoint {
    case viewed(period: Int)
    case emailed(period: Int)
    case shared(period: Int, shareType: String?)

    // MARK: - Properties
    var path: String {
        var path = "/svc/mostpopular/v2"
        switch self {
        case .viewed(let period):
            path += "/viewed/\(period).json"
        case .emailed(let period):
            path += "/emailed/\(period).json"
        case .shared(let period, let shareType):
            path += "/shared/\(period)"
            if let shareType = shareType {
                path += "/\(shareType)"
            }
            path += ".json"
        }
        return path
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
}
