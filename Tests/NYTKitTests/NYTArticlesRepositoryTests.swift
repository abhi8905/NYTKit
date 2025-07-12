//
//  NYTArticlesRepositoryTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
import Foundation
@testable import NYTKit


// MARK: - Mock Network Client
struct MockNetworkClient: NetworkClientProtocol {
    let response: ArticleAPIResponse

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        return response as! T
    }
}

// MARK: - Shared Test Data
let sampleArticle = Article(
    id: 1,
    url: "https://test.com",
    publishedDate: "2025-07-10",
    byline: "By Tester",
    title: "Test Title",
    abstract: "Abstract",
    media: [],
    section: "Tech"
)

let sampleResponse = ArticleAPIResponse(
    status: "OK",
    numResults: 1,
    results: [sampleArticle]
)

let testFilter = MostPopularFilter(endpoint: .viewed, period: .day)


// MARK: - Actual Tests
struct NYTArticlesRepositoryTests {

    @Test("fetches from cache when fresh and skips network")
    func testFetchFromCache() async {
        let mockCache = MockCache()
        let cacheKey = testFilter.cacheKey
        let freshEntry = CacheEntry(creationDate: Date(), value: sampleResponse)
        await mockCache.setRaw(freshEntry, forKey: cacheKey)

        let repo = NYTArticlesRepository(
            networkClient: MockNetworkClient(response: .init(status: "SHOULD_NOT_HIT", numResults: 0, results: [])),
            responseCache: mockCache,
            cacheTTL: 15 * 60
        )

        var collected: [[Article]] = []
        do {
            for try await chunk in repo.fetchArticles(with: testFilter) {
                collected.append(chunk)
            }
        } catch {
            Issue.record("Unexpected error during fetchArticles: \\(error)")
        }
        #expect(collected.count == 1)
        #expect(collected.first?.first?.id == 1)
    }

    @Test("fetches from network and populates cache when missing")
    func testFetchFromNetworkAndCache() async {
        let mockCache = MockCache()

        let repo = NYTArticlesRepository(
            networkClient: MockNetworkClient(response: sampleResponse),
            responseCache: mockCache,
            cacheTTL: 15 * 60
        )

        var collected: [[Article]] = []
        do {
            for try await chunk in repo.fetchArticles(with: testFilter) {
                collected.append(chunk)
            }
        } catch {
            Issue.record("Unexpected error during fetchArticles: \\(error)")
        }

        #expect(collected.count == 1)
        #expect(collected.first?.first?.title == "Test Title")

        let cachedEntry: CacheEntry<ArticleAPIResponse>? = await mockCache.get(forKey: testFilter.cacheKey)
        #expect(cachedEntry?.value.numResults == 1)
    }

    @Test("stale cache still yields but triggers network refresh")
    func testStaleCacheTriggersRefresh() async {
        let mockCache = MockCache()
        let staleDate = Calendar.current.date(byAdding: .minute, value: -20, to: Date())!
        let staleEntry = CacheEntry(creationDate: staleDate, value: sampleResponse)
        await mockCache.setRaw(staleEntry, forKey: testFilter.cacheKey)

        let repo = NYTArticlesRepository(
            networkClient: MockNetworkClient(response: sampleResponse),
            responseCache: mockCache,
            cacheTTL: 15 * 60
        )

        var collected: [[Article]] = []
        do {
            for try await chunk in repo.fetchArticles(with: testFilter) {
                collected.append(chunk)
            }
        } catch {
            Issue.record("Unexpected error during fetchArticles: \\(error)")
        }

        #expect(collected.count == 2)
    }
    
    @Test("NYTEndpoint.from(filter:) covers all endpoint types")
    func testNYTEndpointFromFilterCoversAllCases() {
        let viewedFilter = MostPopularFilter(endpoint: .viewed, period: .day)
        let emailedFilter = MostPopularFilter(endpoint: .emailed, period: .week)
        let sharedFilter = MostPopularFilter(endpoint: .shared, period: .month, shareType: .twitter)

        let viewedEndpoint = NYTEndpoint.from(filter: viewedFilter)
        let emailedEndpoint = NYTEndpoint.from(filter: emailedFilter)
        let sharedEndpoint = NYTEndpoint.from(filter: sharedFilter)

        // Check basic structure
        switch viewedEndpoint {
        case .viewed(let period): #expect(period == 1)
        default: Issue.record("Expected .viewed endpoint")
        }

        switch emailedEndpoint {
        case .emailed(let period): #expect(period == 7)
        default: Issue.record("Expected .emailed endpoint")
        }

        switch sharedEndpoint {
        case .shared(let period, let shareType):
            #expect(period == 30)
            #expect(shareType == "twitter")
        default:
            Issue.record("Expected .shared endpoint")
        }
    }
    
    @Test("throws error when network request fails")
    func testNetworkRequestThrowsError() async {
        struct FailingNetworkClient: NetworkClientProtocol {
            func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
                throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request failed"])
            }
        }

        let mockCache = MockCache()

        let repo = NYTArticlesRepository(
            networkClient: FailingNetworkClient(),
            responseCache: mockCache,
            cacheTTL: 15 * 60
        )

        var didThrow = false

        do {
            for try await _ in repo.fetchArticles(with: testFilter) {
                Issue.record("Should not yield any articles")
            }
        } catch {
            didThrow = true
            #expect((error as NSError).localizedDescription == "Request failed")
        }

        #expect(didThrow == true)
    }
}


actor MockCache: ResponseCacheProtocol, @unchecked Sendable {
    private var store: [String: Data] = [:]

    func get<T: Codable & Sendable>(forKey key: String) async -> CacheEntry<T>? {
        guard let data = store[key] else { return nil }
        return try? JSONDecoder().decode(CacheEntry<T>.self, from: data)
    }

    func set<T: Codable & Sendable>(_ value: T, forKey key: String) async {
        let entry = CacheEntry(creationDate: Date(), value: value)
        store[key] = try? JSONEncoder().encode(entry)
    }

    func setRaw<T: Codable & Sendable>(_ entry: CacheEntry<T>, forKey key: String) async {
        store[key] = try? JSONEncoder().encode(entry)
    }
}
