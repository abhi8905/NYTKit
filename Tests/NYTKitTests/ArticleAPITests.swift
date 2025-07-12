//
//  ArticleAPITests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
import Foundation
@testable import NYTKit

struct ArticleAPITests {
    private let sampleJSON = """
    {
        "status": "OK",
        "num_results": 1,
        "results": [
            {
                "id": 100000010257761,
                "url": "https://www.nytimes.com/2025/07/05/opinion/trump-fbi-politics-safety.html",
                "published_date": "2025-07-05",
                "byline": "By The Editorial Board",
                "title": "Trump’s Politicized F.B.I. Has Made Americans Less Safe",
                "abstract": "The Trump administration’s political witch hunt is risking the bureau’s effectiveness and the public’s safety.",
                "section": "Opinion",
                "media": [
                    {
                        "type": "image",
                        "caption": "",
                        "media-metadata": [
                            {
                                "url": "https://static01.nyt.com/image1.jpg",
                                "format": "Standard Thumbnail",
                                "height": 75,
                                "width": 75
                            },
                            {
                                "url": "https://static01.nyt.com/image2.jpg",
                                "format": "mediumThreeByTwo210",
                                "height": 140,
                                "width": 210
                            }
                        ]
                    }
                ]
            }
        ]
    }
    """

    @Test("Decode API response and core properties")
    func testDecodeArticleAPIResponse() throws {
        let jsonData = Data(sampleJSON.utf8)
        let response = try JSONDecoder().decode(ArticleAPIResponse.self, from: jsonData)

        #expect(response.status == "OK")
        #expect(response.numResults == 1)
        #expect(response.results.count == 1)

        let article = response.results.first!
        #expect(article.id == 100000010257761)
        #expect(article.url.contains("nytimes.com"))
        #expect(article.publishedDate == "2025-07-05")
        #expect(article.byline == "By The Editorial Board")
        #expect(article.title.contains("Trump"))
        #expect(article.abstract.contains("witch hunt"))
        #expect(article.section == "Opinion")
        #expect(article.media.count == 1)

        let media = article.media.first!
        #expect(media.type == "image")
        #expect(media.caption == "")
        #expect(media.mediaMetadata.count == 2)

        let metadata = media.mediaMetadata.first!
        #expect(metadata.url.contains("image1.jpg"))
        #expect(metadata.format == "Standard Thumbnail")
        #expect(metadata.height == 75)
        #expect(metadata.width == 75)
    }

    @Test("Equality based on article ID only")
    func testArticleEquality() {
        let article1 = Article(
            id: 1,
            url: "https://a.com",
            publishedDate: "2025-01-01",
            byline: "Author A",
            title: "Title A",
            abstract: "Abstract A",
            media: [],
            section: "A"
        )

        let article2 = Article(
            id: 1,
            url: "https://b.com",
            publishedDate: "2025-01-02",
            byline: "Author B",
            title: "Title B",
            abstract: "Abstract B",
            media: [],
            section: "B"
        )

        let article3 = Article(
            id: 2,
            url: "https://a.com",
            publishedDate: "2025-01-01",
            byline: "Author A",
            title: "Title A",
            abstract: "Abstract A",
            media: [],
            section: "A"
        )

        #expect(article1 == article2)
        #expect(article1 != article3)
    }

    @Test("Hash values match for same ID")
    func testHashForSameArticleID() {
        let article1 = Article(
            id: 42,
            url: "https://a.com",
            publishedDate: "2025-01-01",
            byline: "Author A",
            title: "Title A",
            abstract: "Abstract A",
            media: [],
            section: "A"
        )

        let article2 = Article(
            id: 42,
            url: "https://b.com",
            publishedDate: "2025-01-02",
            byline: "Author B",
            title: "Title B",
            abstract: "Abstract B",
            media: [],
            section: "B"
        )

        var hasher1 = Hasher()
        var hasher2 = Hasher()
        article1.hash(into: &hasher1)
        article2.hash(into: &hasher2)

        #expect(hasher1.finalize() == hasher2.finalize())
    }

    @Test("MediaMetadata equality")
    func testMediaMetadataEquality() {
        let m1 = MediaMetadata(url: "u", format: "f", height: 1, width: 2)
        let m2 = MediaMetadata(url: "u", format: "f", height: 1, width: 2)
        let m3 = MediaMetadata(url: "diff", format: "x", height: 10, width: 20)

        #expect(m1 == m2)
        #expect(m1 != m3)
    }

    @Test("Decode empty media gracefully")
    func testOptionalMediaArray() throws {
        let json = """
        {
            "status": "OK",
            "num_results": 1,
            "results": [
                {
                    "id": 1,
                    "url": "https://x.com",
                    "published_date": "2025-01-01",
                    "byline": "x",
                    "title": "x",
                    "abstract": "x",
                    "section": "x",
                    "media": []
                }
            ]
        }
        """
        let data = Data(json.utf8)
        let result = try JSONDecoder().decode(ArticleAPIResponse.self, from: data)
        #expect(result.results.first!.media.isEmpty)
    }
}
