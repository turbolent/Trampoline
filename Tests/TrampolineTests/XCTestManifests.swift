import XCTest

extension TrampolineTests {
    static let __allTests = [
        ("testAckermann", testAckermann),
        ("testEvenOdd", testEvenOdd),
        ("testFlatMap", testFlatMap),
        ("testFlatMap2", testFlatMap2),
        ("testFlatMap3", testFlatMap3),
        ("testMap", testMap),
        ("testMap2", testMap2),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TrampolineTests.__allTests),
    ]
}
#endif
