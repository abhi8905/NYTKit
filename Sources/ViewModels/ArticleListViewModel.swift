//
//  ArticleListViewModel.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//

import Foundation
import Combine

@MainActor
public protocol ArticleListViewModelProtocol: ObservableObject {
    var state: ViewState { get }
    var filter: MostPopularFilter { get }

    var statePublisher: Published<ViewState>.Publisher { get }
    var filterPublisher: Published<MostPopularFilter>.Publisher { get }

    func updateFilter(endpoint: MostPopularFilter.EndpointType?, period: MostPopularFilter.Period?)
}

@MainActor
public final class ArticleListViewModel: ArticleListViewModelProtocol {
    
    // MARK: - Public Properties
    @Published public private(set) var state: ViewState = .idle
    @Published public private(set) var filter = MostPopularFilter()

    public var statePublisher: Published<ViewState>.Publisher { $state }
    public var filterPublisher: Published<MostPopularFilter>.Publisher { $filter }


    // MARK: - Private
    private let repository: ArticlesRepository
    private let networkMonitor: NetworkMonitoring
    private var cancellables = Set<AnyCancellable>()
    private var fetchTask: Task<Void, Never>?

    // MARK: - Init
    public init(repository: ArticlesRepository, networkMonitor: NetworkMonitoring) {
        self.repository = repository
        self.networkMonitor = networkMonitor

        observeFilterChanges()
        observeNetworkStatus()
    }

    // MARK: - Observation
    private func observeFilterChanges() {
        $filter
            .debounce(for: .seconds(AppConstants.Timings.filterDebounce), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] in self?.startStream(for: $0) }
            .store(in: &cancellables)
    }

    private func observeNetworkStatus() {
        networkMonitor.isConnectedPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self else { return }
                print("📡 isConnectedPublisher: \(isConnected)")
                if isConnected {
                    if case .offline = self.state {
                        self.state = .loading
                        self.startStream(for: self.filter)
                    }
                } else {
                    self.fetchTask?.cancel()
                    self.state = .offline
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API
    public func updateFilter(endpoint: MostPopularFilter.EndpointType? = nil,
                             period: MostPopularFilter.Period? = nil) {
        var newFilter = self.filter
        var didChange = false

        if let endpoint, filter.endpoint != endpoint {
            newFilter.endpoint = endpoint
            didChange = true
        }

        if let period, filter.period != period {
            newFilter.period = period
            didChange = true
        }

        if didChange {
            self.state = .loading
            self.filter = newFilter
        }
    }

    // MARK: - Fetch Logic
    private func startStream(for filter: MostPopularFilter) {
        guard networkMonitor.isConnected else {
            state = .offline
            return
        }

        fetchTask?.cancel()

        if state.articles.isEmpty {
            state = .loading
        }

        fetchTask = Task {
            do {
                let stream = repository.fetchArticles(with: filter)
                for try await articles in stream {
                    if Task.isCancelled { return }
                    guard articles != state.articles else { continue }

                    state = articles.isEmpty
                        ? .failure(AppConstants.ErrorMessages.noArticles)
                        : .success(articles)
                }
            } catch {
                if Task.isCancelled { return }
                state = .failure(error.localizedDescription)
            }
        }
    }
}

public extension ArticleListViewModelProtocol {
    func resetFilter() {
        updateFilter(endpoint: nil, period: nil)
    }
}
