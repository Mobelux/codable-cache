import XCTest
@testable import CodableCache

struct Test: Codable, Equatable {
    let value: String
}

final class CodableCacheTests: XCTestCase {
    static func wrapper(for test: Test, date: Date) -> CacheWrapper<Test> {
        CacheWrapper(
            ttl: .default,
            created: date,
            object: test)
    }

    static let test = Test(value: "test-value")
    var wrapper: CacheWrapper<Test> {
        CodableCacheTests.wrapper(for: CodableCacheTests.test, date: CodableCache.makeDate())
    }

    override func setUp() {
        let date = Date()
        CodableCache.makeDate = { date }
    }

    func testCache() async throws {
        let data = try CodableCache.encoder.encode(wrapper)

        let mockCache = MockCache(instruction: .data(data))
        let codableCache = CodableCache(mockCache)

        do {
            try await codableCache.cache(object: Self.test, key: "test", ttl: .default)
            XCTAssertEqual(mockCache.callable, .cache)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testThrowingCache() async throws {
        let testError = "throwing-cache"

        let mockCache = MockCache(instruction: .throw(testError))
        let codableCache = CodableCache(mockCache)

        do {
            try await codableCache.cache(object: Self.test, key: "test", ttl: .default)
            XCTFail("Expected failure")
        } catch {
            XCTAssertEqual("\(error)", testError)
            XCTAssertEqual(mockCache.callable, .cache)
        }
    }

    func testData() async throws {
        let testData = try CodableCache.encoder.encode(wrapper)

        let mockCache = MockCache(instruction: .data(testData))
        let codableCache = CodableCache(mockCache)

        let data: Test? = await codableCache.object(key: "test")
        XCTAssertEqual(data, Self.test)
        XCTAssertEqual(mockCache.callable, .data)
    }

    func testStaleData() async throws {
        CodableCache.makeDate = { Date(timeIntervalSinceNow: -Double(TTL.day(2).value)) }
        let testData = try CodableCache.encoder.encode(wrapper)
        let testError = "throwing-data"

        let mockCache = MockCache(instruction: .dataThrow(testData, testError))
        let codableCache = CodableCache(mockCache)

        let data: Test? = await codableCache.object(key: "test")
        XCTAssertEqual(data, nil)
        XCTAssertEqual(mockCache.callable, .delete)
    }

    func testDelete() async throws {
        let mockCache = MockCache(instruction: .none)
        let codableCache = CodableCache(mockCache)

        do {
            try await codableCache.delete(objectWith: "test")
            XCTAssertEqual(mockCache.callable, .delete)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testThrowingDelete() async throws {
        let testError = "throwing-delete"
        let mockCache = MockCache(instruction: .throw(testError))
        let codableCache = CodableCache(mockCache)

        do {
            try await codableCache.delete(objectWith: "test")
            XCTFail("Expected failure")
        } catch {
            XCTAssertEqual("\(error)", testError)
            XCTAssertEqual(mockCache.callable, .delete)
        }
    }

    func testDeleteAll() async throws {
        let mockCache = MockCache(instruction: .none)
        let codableCache = CodableCache(mockCache)

        do {
            try await codableCache.deleteAll()
            XCTAssertEqual(mockCache.callable, .deleteAll)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testThrowingDeleteAll() async throws {
        let testError = "throwing-delete"
        let mockCache = MockCache(instruction: .throw(testError))
        let codableCache = CodableCache(mockCache)

        do {
            try await codableCache.deleteAll()
            XCTFail("Expected failure")
        } catch {
            XCTAssertEqual("\(error)", testError)
            XCTAssertEqual(mockCache.callable, .deleteAll)
        }
    }
}
