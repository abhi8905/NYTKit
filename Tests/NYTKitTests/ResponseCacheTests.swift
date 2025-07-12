//
//  ResponseCacheTests.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Testing
@testable import NYTKit
import Foundation

struct ResponseCacheTests {
    let cache = ResponseCache.shared
    let key = "sample"

    struct Dummy: Codable & Sendable, Equatable {
        let id: Int
    }

    @Test("stores and retrieves Codable objects")
    func testSetAndGet() async {
        let dummy = Dummy(id: 123)
        await cache.set(dummy, forKey: key)

        let result: CacheEntry<Dummy>? = await cache.get(forKey: key)
        #expect(result?.value == dummy)
    }

    @Test("handles decoding failure gracefully")
    func testInvalidData() async {
        let _ = await cache.get(forKey: "nonexistent") as CacheEntry<Dummy>?
    }
    
    @Test("handles encoding failure gracefully")
    func testEncodingFailureHandledGracefully() async {
        struct BadEncodable: Codable & Sendable {
            let value: Double

            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "EncodingError", code: -123, userInfo: nil)
            }

            init(from decoder: Decoder) throws {
                self.value = 0
            }

            init(value: Double) {
                self.value = value
            }
        }

        let cache = ResponseCache.shared
        let key = "bad-encodable"

        await cache.set(BadEncodable(value: 42), forKey: key)

        let result: CacheEntry<BadEncodable>? = await cache.get(forKey: key)

        #expect(result == nil)
    }
    
    @Test("handles decoding failure when type mismatches")
    func testDecodingFailureDueToTypeMismatch() async {
        struct A: Codable & Sendable, Equatable {
            let message: String
        }

        struct B: Codable & Sendable, Equatable {
            let id: Int
        }

        let key = "type-mismatch-key"
        let cache = ResponseCache.shared

        await cache.set(A(message: "hello"), forKey: key)

        let result: CacheEntry<B>? = await cache.get(forKey: key)

        #expect(result == nil)
    }
}

struct BadEncodable: Codable & Sendable {
    let value: Double

    func encode(to encoder: Encoder) throws {
        throw NSError(domain: "EncodingError", code: -123, userInfo: nil)
    }
}
