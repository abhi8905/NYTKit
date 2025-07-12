//
//  NYTEndpointTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
@testable import NYTKit
import Foundation

struct NYTEndpointTests {

    @Test("Viewed endpoint constructs the correct path")
    func testViewedEndpointPath() {
        let endpoint = NYTEndpoint.viewed(period: 7)
        let expectedPath = "/svc/mostpopular/v2/viewed/7.json"
        
        #expect(endpoint.path == expectedPath)
    }
    
    @Test("Emailed endpoint constructs the correct path")
    func testEmailedEndpointPath() {
        let endpoint = NYTEndpoint.emailed(period: 30)
        let expectedPath = "/svc/mostpopular/v2/emailed/30.json"
        
        #expect(endpoint.path == expectedPath)
    }

    @Test("Shared endpoint constructs the correct path with a share type")
    func testSharedEndpointPathWithShareType() {
        let endpoint = NYTEndpoint.shared(period: 1, shareType: "facebook")
        let expectedPath = "/svc/mostpopular/v2/shared/1/facebook.json"
        
        #expect(endpoint.path == expectedPath)
    }
    
    @Test("Shared endpoint constructs the correct path without a share type")
    func testSharedEndpointPathWithoutShareType() {
        let endpoint = NYTEndpoint.shared(period: 7, shareType: nil)
        let expectedPath = "/svc/mostpopular/v2/shared/7.json"
        
        #expect(endpoint.path == expectedPath)
    }
    
    @Test("All endpoints have nil queryItems")
    func testQueryItemsAreNil() {
        let viewedEndpoint = NYTEndpoint.viewed(period: 7)
        let emailedEndpoint = NYTEndpoint.emailed(period: 1)
        let sharedEndpoint = NYTEndpoint.shared(period: 30, shareType: "twitter")
        
        #expect(viewedEndpoint.queryItems == nil)
        #expect(emailedEndpoint.queryItems == nil)
        #expect(sharedEndpoint.queryItems == nil)
    }
}
