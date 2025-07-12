//
//  MostPopularFilterTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
@testable import NYTKit

struct MostPopularFilterTests {
    
    @Test("Default initializer sets expected values")
    func testDefaultInit() {
        let filter = MostPopularFilter()
        #expect(filter.endpoint == .viewed)
        #expect(filter.period == .week)
        #expect(filter.section == "all-sections")
        #expect(filter.shareType == nil)
    }

    @Test("Custom initializer sets all values")
    func testCustomInit() {
        let filter = MostPopularFilter(
            endpoint: .shared,
            period: .day,
            section: "sports",
            shareType: .facebook
        )
        #expect(filter.endpoint == .shared)
        #expect(filter.period == .day)
        #expect(filter.section == "sports")
        #expect(filter.shareType == .facebook)
    }

    @Test("Period displayName and value are correct")
    func testPeriodDisplayProperties() {
        #expect(MostPopularFilter.Period.day.displayName == "1 Day")
        #expect(MostPopularFilter.Period.week.displayName == "7 Days")
        #expect(MostPopularFilter.Period.month.displayName == "30 Days")

        #expect(MostPopularFilter.Period.day.value == "1")
        #expect(MostPopularFilter.Period.week.value == "7")
        #expect(MostPopularFilter.Period.month.value == "30")
    }

    @Test("Equatable returns true for identical filters")
    func testEquatableTrue() {
        let filter1 = MostPopularFilter(endpoint: .emailed, period: .month, section: "tech", shareType: .twitter)
        let filter2 = MostPopularFilter(endpoint: .emailed, period: .month, section: "tech", shareType: .twitter)
        #expect(filter1 == filter2)
    }

    @Test("Equatable returns false for different filters")
    func testEquatableFalse() {
        let filter1 = MostPopularFilter(endpoint: .viewed)
        let filter2 = MostPopularFilter(endpoint: .shared)
        #expect(filter1 != filter2)
    }

    @Test("All Period cases exist and have unique IDs")
    func testPeriodCaseIterable() {
        let allPeriods = MostPopularFilter.Period.allCases
        #expect(allPeriods.count == 3)
        #expect(Set(allPeriods.map(\.id)).count == allPeriods.count)
    }

    @Test("All EndpointType and ShareType have correct identifiers")
    func testIdentifiers() {
        #expect(MostPopularFilter.EndpointType.shared.id == .shared)
        #expect(MostPopularFilter.ShareType.twitter.id == .twitter)
    }
}