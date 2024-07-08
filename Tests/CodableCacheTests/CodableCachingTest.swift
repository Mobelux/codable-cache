//
//  CodableCachingTest.swift
//  
//
//  Created by Jeremy Greenwood on 2/24/22.
//

import XCTest
@testable import CodableCache

class CodableCachingTest: XCTestCase {
    @CodableCaching(
        key: "test",
        cache: { MockCache(
            instruction: .data(
                try! CodableCache.encoder.encode(CacheWrapper(
                    ttl: .default,
                    created: CodableCache.makeDate(),
                    object: "test-value"))
            )) },
        ttl: .default)
    var testValue: String?

    override func setUp() {
        CodableCache.encoder.outputFormatting = .sortedKeys
    }

    func testGetValue() async {
        let value = await $testValue.get()
        XCTAssertEqual(value, "test-value")
        XCTAssertEqual(testValue, "test-value")
    }

    func testSetValue() async {
        await $testValue.set("test-value")
        XCTAssertEqual(testValue, "test-value")
    }

    @CodableCaching(
        key: "test",
        cache: { MockCache(
            instruction: .none) },
        ttl: .default)
    var testNilValue: String?

    func testNilValue() async {
        await $testNilValue.set(nil)
        XCTAssertEqual(testNilValue, nil)
    }
}
