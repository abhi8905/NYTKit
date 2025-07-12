//
//  APIEnvironmentTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
@testable import NYTKit

struct APIEnvironmentTests {

    @Test("Development environment returns correct values")
    func testDevelopmentEnvironment() {
        let environment = DevelopmentEnvironment()
        
        #expect(environment.scheme == "https")
        #expect(environment.host == "api.nytimes.com")
    }
    
    @Test("Production environment returns correct values")
    func testProductionEnvironment() {
        let environment = ProductionEnvironment()
        
        #expect(environment.scheme == "https")
        #expect(environment.host == "api.nytimes.com")
    }
}
