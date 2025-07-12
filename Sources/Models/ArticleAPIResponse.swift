//
//  ArticleAPIResponse.swift
//  NYTimes
//
//  Created by Abhinav Jha on 10/07/2025.
//

import Foundation

public struct ArticleAPIResponse: Codable, Sendable {
    public let status: String
    public let numResults: Int
    public let results: [Article]

    enum CodingKeys: String, CodingKey {
        case status
        case numResults = "num_results"
        case results
    }
}

public struct Article: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let url: String
    public let publishedDate: String
    public let byline: String
    public let title: String
    public let abstract: String
    public let media: [Media]
    public let section: String

    enum CodingKeys: String, CodingKey {
        case id, url
        case publishedDate = "published_date"
        case byline, title, abstract, media, section
    }

    public static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public init(id: Int, url: String, publishedDate: String, byline: String, title: String, abstract: String, media: [Media], section: String) {
        self.id = id
        self.url = url
        self.publishedDate = publishedDate
        self.byline = byline
        self.title = title
        self.abstract = abstract
        self.media = media
        self.section = section
    }
}

public struct Media: Codable, Hashable, Sendable {
    public let type: String
    public let caption: String
    public let mediaMetadata: [MediaMetadata]

    enum CodingKeys: String, CodingKey {
        case type, caption
        case mediaMetadata = "media-metadata"
    }
}

public struct MediaMetadata: Codable, Hashable, Sendable {
    public let url: String
    public let format: String
    public let height: Int
    public let width: Int
}
