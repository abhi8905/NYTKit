//
//  MostPopularFilter.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//


public struct MostPopularFilter: Equatable, Sendable {
    public var endpoint: EndpointType = .viewed
    public var period: Period = .week
    public var section: String = "all-sections"
    public var shareType: ShareType? = nil

    public init(endpoint: EndpointType = .viewed,
                period: Period = .week,
                section: String = "all-sections",
                shareType: ShareType? = nil) {
        self.endpoint = endpoint
        self.period = period
        self.section = section
        self.shareType = shareType
    }

    public enum EndpointType: String, CaseIterable, Identifiable, Sendable {
        case viewed, emailed, shared
        public var id: Self { self }
    }

    public enum ShareType: String, CaseIterable, Identifiable, Sendable {
        case facebook, twitter
        public var id: Self { self }
    }

    public enum Period: Int, CaseIterable, Identifiable, Sendable {
        case day = 1, week = 7, month = 30
        public var id: Self { self }
        public var displayName: String {
            switch self {
            case .day:   return "1 Day"
            case .week:  return "7 Days"
            case .month: return "30 Days"
            }
        }
        public var value: String { String(rawValue) }
    }
}
