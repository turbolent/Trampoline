import XCTest
@testable import Trampoline

class TrampolineTests: XCTestCase {

    func testFlatMap() {
        let trampoline = More { Done(23) }
            .flatMap { Done($0 * 42) }

        XCTAssertEqual(trampoline.run(), 23 * 42)
    }

    func testFlatMap2() {
        let trampoline = More { Done(23) }
            .flatMap { n in More { Done(String(n)) } }
            .flatMap { Done($0 + "42") }

        XCTAssertEqual(trampoline.run(), "2342")
    }

    func testFlatMap3() {
        let trampoline = More {
                Done(23).flatMap { Done($0 * 42) }
            }
            .flatMap { Done(String($0)) }

        XCTAssertEqual(trampoline.run(), String(23 * 42))
    }

    func testMap() {
        let trampoline = More { Done(23) }.map { $0 * 42 }

        XCTAssertEqual(trampoline.run(), 23 * 42)
    }

    func testMap2() {
        let trampoline = Done(23).map { $0 * 42 }

        XCTAssertEqual(trampoline.run(), 23 * 42)
    }

    func testEvenOdd() {
        func even(_ n: Int) -> Trampoline<Bool> {
            if n == 0 {
                return Done(true)
            } else {
                return More { odd(n - 1) }
            }
        }

        func odd(_ n: Int) -> Trampoline<Bool> {
            if n == 0 {
                return Done(false)
            } else {
                return More { even(n - 1) }
            }
        }

        XCTAssertTrue(odd(99999).run())
        XCTAssertTrue(even(100000).run())
        XCTAssertFalse(odd(100000).run())
        XCTAssertFalse(even(99999).run())
    }

    func testAckermann() {
        // The recursive implementation of the Ackermann function
        // results in a stack overflow even for small inputs:
        //
        //    func ackermann(_ m: Int, _ n: Int) -> Int {
        //        if m <= 0 {
        //            return n + 1
        //        }
        //        if n <= 0 {
        //            return ackermann(m - 1, 1)
        //        }
        //        let x = ackermann(m, n - 1)
        //        return ackermann(m - 1, x)
        //    }
        //
        // The following version uses trampolines to avoid
        // the overflow:

        func ackermann(_ m: Int, _ n: Int) -> Trampoline<Int> {
            if m <= 0 {
                return Done(n + 1)
            }
            if n <= 0 {
                return More { ackermann(m - 1, 1) }
            }
            let first = More { ackermann(m, n - 1) }
            let second = { x in More { ackermann(m - 1, x) } }
            return first.flatMap(second)
        }

        XCTAssertEqual(ackermann(1, 2).run(), 4)
        XCTAssertEqual(ackermann(3, 2).run(), 29)
        XCTAssertEqual(ackermann(3, 4).run(), 125)
        XCTAssertEqual(ackermann(3, 7).run(), 1021)
    }

}
