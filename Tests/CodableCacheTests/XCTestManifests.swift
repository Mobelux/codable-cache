import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(codable_cacheTests.allTests),
    ]
}
#endif
