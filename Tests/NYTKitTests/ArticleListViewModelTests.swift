//
//  ArticleListViewModelTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
import Combine
@testable import NYTKit
import Foundation

struct ArticleListViewModelTests {

    @Test("ViewModel emits loading and success states with valid data")
    @MainActor
    func testSuccessFlow() async throws {
        // Arrange
        let mockRepo = MockArticlesRepository()
        let mockNetwork = MockNetworkMonitor()
        mockNetwork.updateConnection(true)

        let articles = [
            Article(
                id: 1,
                url: "https://test.com",
                publishedDate: "2025-07-11",
                byline: "By Tester",
                title: "Test",
                abstract: "Summary",
                media: [],
                section: "Tech"
            )
        ]

        mockRepo.resultStream = AsyncThrowingStream { continuation in
            continuation.yield(articles)
            continuation.finish()
        }

        let viewModel = ArticleListViewModel(repository: mockRepo, networkMonitor: mockNetwork)

        // Act
        viewModel.updateFilter(endpoint: .viewed, period: .day)
        try await Task.sleep(nanoseconds: 600_000_000)

        // Assert
        switch viewModel.state {
        case .success(let output):
            #expect(output == articles)
        default:
            Issue.record("Expected success state, got: \(viewModel.state)")
        }
    }

    @Test("ViewModel sets state to offline when disconnected")
    @MainActor
    func testOfflineState() async {
        let mockRepo = MockArticlesRepository()
        let mockNetwork = MockNetworkMonitor()
        mockNetwork.updateConnection(false)

        let viewModel = ArticleListViewModel(repository: mockRepo, networkMonitor: mockNetwork)

        // Act
        viewModel.updateFilter(endpoint: .viewed, period: .day)
        do {
            try await Task.sleep(nanoseconds: 600_000_000)
        } catch { }

        // Assert
        #expect(viewModel.state == .offline)
    }

    
    @Test("updateFilter updates endpoint and sets loading")
    @MainActor
    func testUpdateFilterEndpointChange() async {
        let vm = ArticleListViewModel(
            repository: MockArticlesRepository(),
            networkMonitor: MockNetworkMonitor()
        )

        vm.updateFilter(endpoint: .emailed)

        #expect(vm.filter.endpoint == .emailed)
        #expect(vm.state == .loading)
    }

    @Test("updateFilter updates period and sets loading")
    @MainActor
    func testUpdateFilterPeriodChange() async {
        let vm = ArticleListViewModel(
            repository: MockArticlesRepository(),
            networkMonitor: MockNetworkMonitor()
        )

        vm.updateFilter(period: .week)

        #expect(vm.filter.period == .week)
        #expect(vm.state == .idle)
    }

    @Test("updateFilter updates both and sets loading")
    @MainActor
    func testUpdateFilterBothChanges() async {
        let vm = ArticleListViewModel(
            repository: MockArticlesRepository(),
            networkMonitor: MockNetworkMonitor()
        )

        vm.updateFilter(endpoint: .shared, period: .month)

        #expect(vm.filter.endpoint == .shared)
        #expect(vm.filter.period == .month)
        #expect(vm.state == .loading)
    }

    @Test("updateFilter with same values does not trigger loading")
    @MainActor
    func testUpdateFilterNoChange() async {
        let vm = ArticleListViewModel(
            repository: MockArticlesRepository(),
            networkMonitor: MockNetworkMonitor()
        )

        let current = vm.filter
        vm.updateFilter(endpoint: current.endpoint, period: current.period)

        #expect(vm.state == .idle)
        #expect(vm.filter == current)
    }
    
    @Test("resetFilter with same values")
    @MainActor
    func testResetFilterNoChange() async {
        let vm = ArticleListViewModel(
            repository: MockArticlesRepository(),
            networkMonitor: MockNetworkMonitor()
        )

        let current = vm.filter
        vm.resetFilter()

        #expect(vm.state == .idle)
        #expect(vm.filter == current)
    }
    
    @Test("ViewModel retries fetch and changes state to success when network reconnects")
    @MainActor
    func testReconnectTriggersFetch() async throws {
        // Arrange
        let mockRepo = MockArticlesRepository()
        let mockNetwork = MockNetworkMonitor(initialStatus: false)

        let articles = [
            Article(
                id: 1,
                url: "https://test.com",
                publishedDate: "2025-07-11",
                byline: "By Tester",
                title: "Test",
                abstract: "Summary",
                media: [],
                section: "Tech"
            )
        ]

        mockRepo.resultStream = AsyncThrowingStream { continuation in
            continuation.yield(articles)
            continuation.finish()
        }

        let viewModel = ArticleListViewModel(repository: mockRepo, networkMonitor: mockNetwork)

        viewModel.updateFilter(endpoint: .viewed, period: .day)
        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(viewModel.state == .offline)

        mockNetwork.updateConnection(true)
        try await Task.sleep(nanoseconds: 600_000_000)

        switch viewModel.state {
        case .success(let result):
            #expect(result == articles)
        default:
            Issue.record("Expected .success state, got: \(viewModel.state)")
        }
    }
    
    @Test("sets failure state when repository throws an error")
    @MainActor
    func testStreamFailureHandling() async throws {
        let mockRepo = MockArticlesRepository()
        let mockNetwork = MockNetworkMonitor(initialStatus: true)

        mockRepo.resultStream = AsyncThrowingStream { continuation in
            continuation.finish(throwing: NSError(domain: "TestError", code: -99, userInfo: [NSLocalizedDescriptionKey: "Stream failed"]))
        }

        let viewModel = ArticleListViewModel(repository: mockRepo, networkMonitor: mockNetwork)

        viewModel.updateFilter(endpoint: .viewed, period: .day)
        try await Task.sleep(nanoseconds: 600_000_000)

        switch viewModel.state {
        case .failure(let message):
            #expect(message == "Stream failed")
        default:
            Issue.record("Expected failure state, got: \(viewModel.state)")
        }
    }
}

final class MockArticlesRepository: ArticlesRepository {
    var resultStream: AsyncThrowingStream<[Article], Error>?

    func fetchArticles(with filter: MostPopularFilter) -> AsyncThrowingStream<[Article], Error> {
        resultStream ?? AsyncThrowingStream { continuation in
            continuation.finish(throwing: NSError(domain: "MockNotSet", code: -1))
        }
    }
}

final class MockNetworkMonitor: NetworkMonitoring, @unchecked Sendable {
    private let subject: CurrentValueSubject<Bool, Never>

    init(initialStatus: Bool = true) {
        self.subject = CurrentValueSubject(initialStatus)
    }

    var isConnected: Bool {
        subject.value
    }

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }

    func updateConnection(_ value: Bool) {
        subject.send(value)
    }
}
