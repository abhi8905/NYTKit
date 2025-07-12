//
//  ArticleDetailViewModelTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
@testable import NYTKit
import Foundation


struct ArticleDetailViewModelTests {

    @Test func testFormattedTextsAndURLs() {
        let article = Article(
            id: 1001,
            url: "https://www.nytimes.com/sample",
            publishedDate: "2025-07-11",
            byline: "Test Author",
            title: "Test Title",
            abstract: "Test Abstract",
            media: [
                Media(
                    type: "image",
                    caption: "",
                    mediaMetadata: [
                        MediaMetadata(
                            url: "https://example.com/image.jpg",
                            format: "mediumThreeByTwo440",
                            height: 293,
                            width: 440
                        )
                    ]
                )
            ],
            section: "World"
        )

        let vm = ArticleDetailViewModel(article: article)

        #expect(vm.titleText == "Test Title")
        #expect(vm.bylineText == "By Test Author")
        #expect(vm.abstractText == "Test Abstract")
        #expect(vm.sectionText == "World")
        #expect(vm.publishedDateString == "2025-07-11")
        #expect(vm.imageURL?.absoluteString == "https://example.com/image.jpg")
        #expect(vm.articleURL?.absoluteString == "https://www.nytimes.com/sample")
    }

    @Test func testImageURLReturnsNilWhenFormatMissing() {
        let article = Article(
            id: 1002,
            url: "https://nyt.com",
            publishedDate: "2025-07-01",
            byline: "Author",
            title: "No Image Format",
            abstract: "Abstract",
            media: [
                Media(
                    type: "image",
                    caption: "",
                    mediaMetadata: [
                        MediaMetadata(
                            url: "https://example.com/other.jpg",
                            format: "Standard Thumbnail",
                            height: 75,
                            width: 75
                        )
                    ]
                )
            ],
            section: "Opinion"
        )

        let vm = ArticleDetailViewModel(article: article)
        #expect(vm.imageURL == nil)
    }
}
