//
//  NetworkClientTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//

import Foundation
import Testing
@testable import NYTKit

struct NetworkClientTests {
    
    // MARK: - Mocks
    
    struct MockEnvironment: APIEnvironment {
        var scheme = "https"
        var host = "mockapi.com"
    }
    
    struct MockEndpoint: Endpoint {
        var path = "/test"
        var queryItems: [URLQueryItem]? = [URLQueryItem(name: "test", value: "value")]
    }
    
    struct BadEndpoint: Endpoint {
        var path = "://"
        var queryItems: [URLQueryItem]? = nil
    }
    
    struct MockResponse: Codable, Equatable {
        let id: Int
        let name: String
    }
    
    class MockSession: URLSessionProtocol {
        var mockData: Data?
        var mockResponse: URLResponse?
        var mockError: Error?

        func data(from url: URL) async throws -> (Data, URLResponse) {
            if let error = mockError { throw error }
            guard let data = mockData, let response = mockResponse else {
                throw URLError(.badServerResponse)
            }
            return (data, response)
        }
    }
    
    final class MockBundle: Bundle, @unchecked Sendable {
        private let testApiKey: String?

        init(apiKey: String?) {
            self.testApiKey = apiKey
            super.init()
        }

        override func object(forInfoDictionaryKey key: String) -> Any? {
            if key == "NYT_API_KEY" {
                return testApiKey
            }
            return super.object(forInfoDictionaryKey: key)
        }
    }

    // MARK: - Tests

    @Test("Throws if API key is missing")
    func testMissingAPIKey() async {
        let client = NetworkClient(
            environment: MockEnvironment(),
            session: MockSession()
        )

        do {
            let _: MockResponse = try await client.request(endpoint: MockEndpoint())
            Issue.record("Expected APIError.missingAPIKey")
        } catch let error as APIError {
            #expect(errorDescription(of: error) == APIError.missingAPIKey.errorDescription)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
    
    @Test("convenience init uses correct environment")
    func testConvenienceInitEnvironment() {
        let client = NetworkClient()
        
        #if DEBUG
        #expect(client.environment is DevelopmentEnvironment)
        #else
        #expect(client.environment is ProductionEnvironment)
        #endif
    }

    @Test("Throws if URL is invalid")
    func testInvalidURL() async {
        let client = NetworkClient(
            environment: MockEnvironment(),
            session: MockSession(),
            bundle: MockBundle(apiKey: "test_key")
        )

        do {
            let _: MockResponse = try await client.request(endpoint: BadEndpoint())
            Issue.record("Expected APIError.invalidURL")
        } catch let error as APIError {
            #expect(errorDescription(of: error) == APIError.invalidURL.errorDescription)
        } catch {
            Issue.record("Unexpected error type: \(type(of: error)) — \(error.localizedDescription)")
        }
    }

    @Test("Throws for bad HTTP status code")
    func testBadStatusCode() async throws {
        let session = MockSession()
        session.mockData = Data()
        session.mockResponse = HTTPURLResponse(
            url: URL(string: "https://mockapi.com/test")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        let client = NetworkClient(
            environment: MockEnvironment(),
            session: session,
            bundle: MockBundle(apiKey: "test_key")
        )

        do {
            let _: MockResponse = try await client.request(endpoint: MockEndpoint())
            Issue.record("Expected APIError.invalidResponse")
        } catch let error as APIError {
            #expect(errorDescription(of: error)?.contains("200") == false)
        }
    }

    @Test("Throws decoding error on invalid data")
    func testDecodingError() async throws {
        let session = MockSession()
        session.mockData = Data("invalid-json".utf8)
        session.mockResponse = HTTPURLResponse(
            url: URL(string: "https://mockapi.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let client = NetworkClient(
            environment: MockEnvironment(),
            session: session,
            bundle: MockBundle(apiKey: "test_key")
        )

        do {
            let _: MockResponse = try await client.request(endpoint: MockEndpoint())
            Issue.record("Expected APIError.decodingError")
        } catch let error as APIError {
            #expect(errorDescription(of: error) == APIError.decodingError.localizedDescription)
        }
    }

    @Test("Returns successfully decoded object")
    func testSuccessResponse() async throws {
        let expected = MockResponse(id: 1, name: "Test")
        let data = try JSONEncoder().encode(expected)

        let session = MockSession()
        session.mockData = data
        session.mockResponse = HTTPURLResponse(
            url: URL(string: "https://mockapi.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let client = NetworkClient(
            environment: MockEnvironment(),
            session: session,
            bundle: MockBundle(apiKey: "test_key")
        )

        let result: MockResponse = try await client.request(endpoint: MockEndpoint())
        #expect(result == expected)
    }
}

// MARK: - Helpers

func errorDescription(of error: Error) -> String? {
    (error as? LocalizedError)?.errorDescription
}
