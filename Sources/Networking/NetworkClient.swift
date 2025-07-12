//
//  NetworkClient.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//

import Foundation

public protocol NetworkClientProtocol: Sendable {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
}

public protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

public final class NetworkClient: NetworkClientProtocol {
    // MARK: - Properties
    public let environment: APIEnvironment
    private let session: URLSessionProtocol
    private let bundle: Bundle

    private var apiKey: String? {
        bundle.object(forInfoDictionaryKey: "NYT_API_KEY") as? String
    }
    
    // MARK: - Initializers
    public init(environment: APIEnvironment, session: URLSessionProtocol = URLSession.shared, bundle: Bundle = .main) {
        self.environment = environment
        self.session = session
        self.bundle = bundle
    }
    
    public convenience init() {
        #if DEBUG
        self.init(environment: DevelopmentEnvironment())
        #else
        self.init(environment: ProductionEnvironment())
        #endif
    }

    // MARK: - API
    public func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard let key = apiKey, !key.isEmpty else {
            throw APIError.missingAPIKey
        }
        var components = URLComponents()
        components.scheme = environment.scheme
        components.host = environment.host
        components.path = endpoint.path
        
        var queryItems = endpoint.queryItems ?? []
        queryItems.append(URLQueryItem(name: "api-key", value: key))
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw APIError.invalidResponse(statusCode: statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}

public enum APIError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse(statusCode: Int?)
    case decodingError

    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing or empty NYT_API_KEY in Info.plist."
        case .invalidURL:
            return "The URL constructed for the API request was invalid."
        case .invalidResponse(let statusCode):
            if let code = statusCode {
                return "The API returned an invalid response: Status Code \(code)."
            } else {
                return "The API returned a non-HTTP response."
            }
        case .decodingError:
            return "Failed to decode the object from the service."
        }
    }
}

extension NetworkClient: @unchecked Sendable {}
