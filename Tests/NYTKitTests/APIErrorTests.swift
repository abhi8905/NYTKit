//
//  APIErrorTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 12/07/2025.
//


import Foundation
import Testing
@testable import NYTKit

struct APIErrorTests {
    
    @Test("missingAPIKey returns correct error description")
    func testMissingAPIKeyDescription() {
        let error = APIError.missingAPIKey
        #expect(error.localizedDescription == "Missing or empty NYT_API_KEY in Info.plist.")
    }

    @Test("invalidURL returns correct error description")
    func testInvalidURLDescription() {
        let error = APIError.invalidURL
        #expect(error.localizedDescription == "The URL constructed for the API request was invalid.")
    }

    @Test("invalidResponse with code returns correct error description")
    func testInvalidResponseWithCode() {
        let error = APIError.invalidResponse(statusCode: 403)
        #expect(error.localizedDescription == "The API returned an invalid response: Status Code 403.")
    }

    @Test("invalidResponse with nil code returns correct fallback description")
    func testInvalidResponseNilCode() {
        let error = APIError.invalidResponse(statusCode: nil)
        #expect(error.localizedDescription == "The API returned a non-HTTP response.")
    }

    @Test("decodingError returns correct error description")
    func testDecodingErrorDescription() {
        let error = APIError.decodingError
        #expect(error.localizedDescription == "Failed to decode the object from the service.")
    }
}
