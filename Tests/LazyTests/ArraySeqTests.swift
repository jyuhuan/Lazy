import XCTest
@testable import Lazy

class ArraySeqTests: XCTestCase {
    
    func testCreateEmptyArraySeq() {
        let arr = ArraySeq<String>.empty()
        assert(arr.count == 0)
        for _ in arr.swiftSequence {
            assert(false)  // Should never enter here
        }
    }
    
    func testCreateArraySeqOutOfElements() {
        let arr = ArraySeq.of(elements: "a", "b")
        assert(arr.count == 2)
        for (i, x) in arr.indexed.swiftSequence {
            assert(x == arr[i])
        }
    }
    
    func testCreateArrayByFillingPlainNumbers() {
        let arr = ArraySeq.fill(5, 8)
        assert(arr.count == 5)
        for x in arr.swiftSequence {
            assert(x == 8)
        }
    }

    func testCreateArraySeqByFillingResultsFromAFunction() {
        // Most common use case: Array.fill(5, arc4random())
        // Need to pass by name
        var i = -1
        func newNumber() -> Int {
            i += 1
            return i
        }
        let arr = ArraySeq.fill(5, newNumber())
        for (i, x) in arr.indexed.swiftSequence {
            assert(x == i)
        }
    }
    
    func testCreateArraySeqByTabulating() {
        let arr = ArraySeq.tabulate(5){i in return i * 10}
        assert(arr.count == 5)
        for (i, x) in arr.indexed.swiftSequence {
            assert(x == i * 10)
        }
    }
    
}

