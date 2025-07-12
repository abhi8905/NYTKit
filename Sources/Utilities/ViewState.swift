//
//  ViewState.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//


public enum ViewState: Equatable {
    case idle
    case loading
    case success([Article])
    case failure(String)
    case offline


    public static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.success(let lhsArticles), .success(let rhsArticles)):
            return lhsArticles == rhsArticles
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError == rhsError
        case (.offline, .offline):
            return true
        default:
            return false
        }
    }
    
    public var articles: [Article] {
        if case .success(let articles) = self {
            return articles
        }
        return []
    }
}
