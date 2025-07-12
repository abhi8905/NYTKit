//
//  ArticleDetailViewModel.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Foundation
import Combine

public final class ArticleDetailViewModel: ObservableObject {
    
    private enum Constants {
        public static let bylinePrefix = "By "
        public static let detailImageFormat = "mediumThreeByTwo440"
    }
    
    private let model: Article

    public init(article: Article) {
        self.model = article
    }

    public var titleText: String {
        model.title
    }

    public var abstractText: String {
        model.abstract
    }

    public var sectionText: String {
        model.section.capitalized
    }

    public var bylineText: String {
        Constants.bylinePrefix + model.byline
    }

    public var publishedDateString: String {
        model.publishedDate
    }

    public var imageURL: URL? {
        if let urlString = model.media.first?.mediaMetadata.first(where: { $0.format == Constants.detailImageFormat })?.url {
            return URL(string: urlString)
        }
        return nil
    }

    public var articleURL: URL? {
        URL(string: model.url)
    }
}
