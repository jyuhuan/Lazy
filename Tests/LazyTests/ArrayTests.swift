import XCTest
@testable import Lazy

class ArrayTests: XCTestCase {
    
    func testCreateEmptyArray() {
        let arr = Lazy.Array<String>.empty()
        assert(arr.count == 0)
        for _ in arr.swiftSequence {
            assert(false)  // Should never enter here
        }
    }
    
    func testCreateArrayOutOfElements() {
        let arr = Lazy.Array.of(elements: "a", "b")
        assert(arr.count == 2)
        for (i, x) in arr.indexed.swiftSequence {
            assert(x == arr[i])
        }
    }
    
    func testCreateArrayByFillingPlainNumbers() {
        let arr = Array.fill(5, 8)
        assert(arr.count == 5)
        for x in arr.swiftSequence {
            assert(x == 8)
        }
    }

    func testCreateArrayByFillingResultsFromAFunction() {
        var i = -1
        func newNumber() -> Int {
            i += 1
            return i
        }
        let arr = Lazy.Array.fill(5, newNumber())
        for (i, x) in arr.indexed.swiftSequence {
            assert(x == i)
        }
    }
    
    func testCreateArrayByTabulating() {
        let arr = Lazy.Array.tabulate(5){i in return i * 10}
        assert(arr.count == 5)
        for (i, x) in arr.indexed.swiftSequence {
            assert(x == i * 10)
        }
    }
    
}

