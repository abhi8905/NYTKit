//
//  NYTArticlesRepository.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//


import Foundation

// MARK: - Protocol Definition
public protocol ArticlesRepository {
    func fetchArticles(with filter: MostPopularFilter) -> AsyncThrowingStream<[Article], Error>
}

// MARK: - Concrete Implementation
public final class NYTArticlesRepository: ArticlesRepository {
    // MARK: - Properties
    private let networkClient: NetworkClientProtocol
    private let responseCache: ResponseCacheProtocol
    private let cacheTTL: TimeInterval
    
    // MARK: - Initializer
    public init(networkClient: NetworkClientProtocol = NetworkClient(), responseCache: ResponseCacheProtocol = ResponseCache.shared, cacheTTL: TimeInterval = 15 * 60) {
        self.networkClient = networkClient
        self.responseCache = responseCache
        self.cacheTTL = cacheTTL
    }
    
    public func fetchArticles(
        with filter: MostPopularFilter
    ) -> AsyncThrowingStream<[Article], Error> {
        let cacheKey = filter.cacheKey
        let ttl = cacheTTL
        let client = networkClient
        let cacheActor = responseCache
        let endpoint = NYTEndpoint.from(filter: filter)
        
        return AsyncThrowingStream { continuation in
            let work = Task {
                if let entry: CacheEntry<ArticleAPIResponse> = await cacheActor.get(forKey: cacheKey) {
                    continuation.yield(entry.value.results)
                    let age = Date().timeIntervalSince(entry.creationDate)
                    if age < ttl {
                        continuation.finish()
                        return
                    }
                }
                
                do {
                    let resp: ArticleAPIResponse = try await client.request(endpoint: endpoint)
                    await cacheActor.set(resp, forKey: cacheKey)
                    continuation.yield(resp.results)
                } catch {
                    continuation.finish(throwing: error)
                    return
                }
                
                continuation.finish()
            }
            
            continuation.onTermination = { @Sendable _ in
                work.cancel()
            }
        }
    }
}

// MARK: - Helper Extensions
extension MostPopularFilter {
    var cacheKey: String {
        let shareTypeString = shareType?.rawValue ?? "none"
        return "\(endpoint.rawValue)-\(period.rawValue)-\(section)-\(shareTypeString)"
    }
}

extension NYTEndpoint {
    public static func from(filter: MostPopularFilter) -> NYTEndpoint {
        switch filter.endpoint {
        case .viewed:
            return .viewed(period: filter.period.rawValue)
        case .emailed:
            return .emailed(period: filter.period.rawValue)
        case .shared:
            return .shared(period: filter.period.rawValue, shareType: filter.shareType?.rawValue)
        }
    }
}
