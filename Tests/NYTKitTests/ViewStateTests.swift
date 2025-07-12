//
//  ViewStateTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
@testable import NYTKit

struct ViewStateTests {
    
    @Test("Idle states are equal")
    func testIdleEquality() {
        #expect(ViewState.idle == ViewState.idle)
    }
    
    @Test("Loading states are equal")
    func testLoadingEquality() {
        #expect(ViewState.loading == ViewState.loading)
    }

    @Test("Offline states are equal")
    func testOfflineEquality() {
        #expect(ViewState.offline == ViewState.offline)
    }

    @Test("Success states with same articles are equal")
    func testSuccessEquality() {
        let articles = [
            Article(id: 1, url: "url", publishedDate: "date", byline: "by", title: "title", abstract: "abs", media: [], section: "section")
        ]
        #expect(ViewState.success(articles) == ViewState.success(articles))
    }

    @Test("Success states with different articles are not equal")
    func testSuccessInequality() {
        let a1 = Article(id: 1, url: "url", publishedDate: "date", byline: "by", title: "title", abstract: "abs", media: [], section: "section")
        let a2 = Article(id: 2, url: "url2", publishedDate: "date2", byline: "by2", title: "title2", abstract: "abs2", media: [], section: "section2")
        #expect(ViewState.success([a1]) != ViewState.success([a2]))
    }

    @Test("Failure states with same error message are equal")
    func testFailureEquality() {
        #expect(ViewState.failure("Network Error") == ViewState.failure("Network Error"))
    }

    @Test("Failure states with different messages are not equal")
    func testFailureInequality() {
        #expect(ViewState.failure("A") != ViewState.failure("B"))
    }

    @Test("Different enum cases are not equal")
    func testDifferentCasesNotEqual() {
        #expect(ViewState.idle != ViewState.loading)
        #expect(ViewState.loading != ViewState.offline)
        #expect(ViewState.success([]) != ViewState.failure("err"))
    }
}