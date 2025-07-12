//
//  Endpoint.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//


import Foundation

public protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}
