//
//  ImageCacheTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
import UIKit
@testable import NYTKit

struct ImageCacheTests {
    
    @Test("Real ImageCache stores and retrieves image correctly")
    func testRealImageCacheSetAndGet() async {
        let cache = ImageCache.shared
        let key = "real-sample"
        guard let image = UIImage(systemName: "star") else {
            Issue.record("Failed to load test image.")
            return
        }

        await cache.set(image, forKey: key)
        let cachedImage = await cache.get(forKey: key)

        #expect(cachedImage != nil)
        #expect(cachedImage?.pngData() == image.pngData())
    }

    @Test("Real ImageCache clears all entries")
    func testRealImageCacheClear() async {
        let cache = ImageCache.shared
        guard let image = UIImage(systemName: "star") else {
            Issue.record("Failed to load test image.")
            return
        }

        await cache.set(image, forKey: "real-one")
        await cache.set(image, forKey: "real-two")

        await cache.clear()

        #expect(await cache.get(forKey: "real-one") == nil)
        #expect(await cache.get(forKey: "real-two") == nil)
    }
}
