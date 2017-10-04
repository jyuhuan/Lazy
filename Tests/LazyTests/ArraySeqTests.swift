import XCTest
@testable import Lazy

class ArraySeqTests: XCTestCase {
    
    func testCreateEmpty() {
        let arr = ArraySeq<String>.empty()
        assert(arr.count == 0)
        for _ in arr.swiftSequence {
            XCTAssert(false)  // Should never enter here
        }
    }
    
    func testCreateOutOfElements() {
        let arr = ArraySeq.of(elements: "a", "b")
        assert(arr.count == 2)
        for (i, x) in arr.indexed.swiftSequence {
            XCTAssert(x == arr[i])
        }
    }
    
    func testCreateByFillingPlainNumbers() {
        let arr = ArraySeq.fill(5, 8)
        assert(arr.count == 5)
        for x in arr.swiftSequence {
            XCTAssert(x == 8)
        }
    }

    func testCreateByFillingResultsFromAFunction() {
        // Most common use case: Array.fill(5, arc4random())
        // Need to pass by name
        var i = -1
        func newNumber() -> Int {
            i += 1
            return i
        }
        let arr = ArraySeq.fill(5, newNumber())
        for (i, x) in arr.indexed.swiftSequence {
            XCTAssert(x == i)
        }
    }
    
    func testCreateByTabulating() {
        let arr = ArraySeq.tabulate(5){i in return i * 10}
        assert(arr.count == 5)
        for (i, x) in arr.indexed.swiftSequence {
            XCTAssert(x == i * 10)
        }
    }
    
    func testIndexed() {
        let arr = ["alice", "bob", "catherine", "daniel", "emily"]
        let xs = ArraySeq<String>(elements: arr)
        for (i, x) in xs.indexed.swiftSequence {
            XCTAssert(arr[i] == x)
        }
    }
    
    func testMappedBy() {
        let xs: ArraySeq<String> = ArraySeq<String>.of(elements: "alice", "bob", "catherine", "daniel", "emily")
        let ys = xs.mapped(by: {s in s.count})
        let arr = ys.toArray()
        XCTAssert(arr[0] == 5)
        XCTAssert(arr[1] == 3)
        XCTAssert(arr[2] == 9)
        XCTAssert(arr[3] == 6)
        XCTAssert(arr[4] == 5)
    }
    
    func testMap() {
        let xs: ArraySeq<String> = ArraySeq<String>.of(elements: "alice", "bob", "catherine", "daniel", "emily")
        let ys = xs.map{s in s.count}
        let arr = ys.toArray()
        XCTAssert(arr[0] == 5)
        XCTAssert(arr[1] == 3)
        XCTAssert(arr[2] == 9)
        XCTAssert(arr[3] == 6)
        XCTAssert(arr[4] == 5)
    }
    
    func testFilteredBy() {
        let xs = ArraySeq.of(elements: "alice", "bob", "catherine", "david", "emily")
        let ys = xs.filtered(by: {x in x.count <= 3})
        XCTAssert(ys.size == 1)
        let arr = ys.toArray()
        XCTAssert(arr.count == 1)
        XCTAssert(arr[0] == "bob")
    }
    
    func testFilter() {
        let xs = ArraySeq.of(elements: "alice", "bob", "catherine", "david", "emily")
        let ys = xs.filter{x in x.count <= 3}
        XCTAssert(ys.size == 1)
        let arr = ys.toArray()
        XCTAssert(arr.count == 1)
        XCTAssert(arr[0] == "bob")
    }

    func testConsecutiveGrouped() {
        let xs = ArraySeq.of(elements: "alice", "bob", "catherine", "david", "emily")
    }

    func testFlatMappedBy() {
        let xs = ArraySeq.of(elements: "alice", "bob")
        let ys = xs.flatMapped(by: {s in ArraySeq(elements: Array(s))})
        let observedIter = ys.toArray()
        let expectedIter = Array("alicebob")
        for (o, e) in zip(observedIter, expectedIter) {
            XCTAssert(o == e)
        }
    }
    
    func testFlatMap() {
        let xs = ArraySeq.of(elements: "alice", "bob")
        let ys = xs.flatMap{s in ArraySeq(elements: Array(s))}
        let observedIter = ys.toArray()
        let expectedIter = Array("alicebob")
        for (o, e) in zip(observedIter, expectedIter) {
            XCTAssert(o == e)
        }
    }
    
    func testGroupConsecutivelyBy() {
        let xs: ArraySeq<Int> = ArraySeq.of(elements: 1, 4, 7, 2, 5, 2, 0, 3, 1 )
        let ys: GroupedConsecutivelyByIterable<ArraySeq<Int>, Int> = xs.groupedConsecutively { (s: Int) -> Int in
            return s % 3
        }
        
        let outer = ys.toArray()
        XCTAssert(outer.count == 4)
        
        let inner0 = outer[0].toArray()
        let inner1 = outer[1].toArray()
        let inner2 = outer[2].toArray()
        let inner3 = outer[3].toArray()
        
        XCTAssert(inner0 == [1, 4, 7])
        XCTAssert(inner1 == [2, 5, 2])
        XCTAssert(inner2 == [0, 3])
        XCTAssert(inner3 == [1])

    }
    
}

