//
//  IterableTest.swift
//  LazyTests
//
//  Created by Yuhuan Jiang on 10/4/17.
//

import XCTest
@testable import Lazy

class TestableIterator<X>: IteratorProtocol {
    typealias Element = X
    
    let arr: [X]
    var i: Int
    
    init(_ arr: [X]) {
        self.arr = arr
        self.i = 0
    }
 
    func next() -> X? {
        if i < arr.count {
            let j = i
            i += 1
            return arr[j]
        }
        else { return nil }
    }
}

class TestableIterable<X>: IterableProtocol {
    typealias Element = X
    typealias Iterator = TestableIterator<X>
    
    let arr: [X]
    
    init(_ arr: [X]) {
        self.arr = arr
    }
    
    func makeIterator() -> TestableIterator<X> {
        return TestableIterator(arr)
    }
}


class IterableTests: XCTestCase {

    func testMap() {
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        let ys = xs.mapped(by: {$0.count})
        let zs = xs.map{$0.count}
        XCTAssert(ys.toArray() == [5, 3, 9, 6])
        XCTAssert(zs.toArray() == [5, 3, 9, 6])
    }
    
    func testFlatMap() {
        func stringToCharacters(_ str: String) -> TestableIterable<Character> {
            return TestableIterable(Array(str.characters))
        }
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        let ys = xs.flatMapped(by: stringToCharacters)
        let zs = xs.flatMap(stringToCharacters)
        let expectedArr = Array("alicebobcatherinedaniel".characters)
        XCTAssert(ys.toArray() == expectedArr)
        XCTAssert(zs.toArray() == expectedArr)
    }

    func testFlatMapWithEmptyTarget() {
        func stringToCharacters(_ str: String) -> TestableIterable<Character> {
            if str == "bob" {
                return TestableIterable([])
            }
            else {
                return TestableIterable(Array(str.characters))
            }
        }
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        let zs = xs.flatMap(stringToCharacters)
        let expectedArr = Array("alicecatherinedaniel".characters)
        XCTAssert(zs.toArray() == expectedArr)
    }
    
    func testFlatMapOnEmptyIterable() {
        func stringToCharacters(_ str: String) -> TestableIterable<Character> {
            if str == "bob" {
                return TestableIterable([])
            }
            else {
                return TestableIterable(Array(str.characters))
            }
        }
        let xs = TestableIterable<String>([])
        let zs = xs.flatMap(stringToCharacters)
        let expectedArr = Array("".characters)
        XCTAssert(zs.toArray() == expectedArr)
    }
    
    func testFilter() {
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        let bs = xs.filter{$0.count <= 5}
        let cs = xs.filtered(by: {$0.count <= 5})
        let ds = xs.filterNot{$0.count <= 5}
        let es = xs.filtered(notBy: {$0.count <= 5})
        
        XCTAssert(bs.toArray() == ["alice", "bob"])
        XCTAssert(cs.toArray() == ["alice", "bob"])
        XCTAssert(ds.toArray() == ["catherine", "daniel"])
        XCTAssert(es.toArray() == ["catherine", "daniel"])
    }
    
    
    
    func testIndexed() {
        let arr = ["alice", "bob", "catherine", "daniel"]
        let xs = TestableIterable(arr)
        for (i, x) in xs.indexed.asSwiftSequence {
            XCTAssert(arr[i] == x)
        }
    }
    
    func testZip() {
        let xArr = ["alice", "bob", "catherine", "daniel"]
        let xs = TestableIterable(xArr)
        let yArr = [5, 3, 9, 6]
        let ys = TestableIterable(yArr)
        
        let bs = xs.zipped(with: ys)
        for (i, (x, y)) in bs.indexed.asSwiftSequence {
            XCTAssert(xArr[i] == x)
            XCTAssert(yArr[i] == y)
        }
        
        let cs = xs.zip(ys)
        for (i, (x, y)) in cs.indexed.asSwiftSequence {
            XCTAssert(xArr[i] == x)
            XCTAssert(yArr[i] == y)
        }
        
        let ds = xs ⛙ ys
        for (i, (x, y)) in ds.indexed.asSwiftSequence {
            XCTAssert(xArr[i] == x)
            XCTAssert(yArr[i] == y)
        }
    }
    
    func testZipIterablesWithDifferentNumOfElems() {
        let xArr = ["alice", "bob", "catherine", "daniel"]
        let xs = TestableIterable(xArr)
        let yArr = [5, 3, 9]
        let ys = TestableIterable(yArr)
        
        let cs = xs ⛙ ys
        XCTAssert(cs.size == 3)
        for (i, (x, y)) in cs.indexed.asSwiftSequence {
            XCTAssert(xArr[i] == x)
            XCTAssert(yArr[i] == y)
        }
        
        let ds = ys ⛙ xs
        XCTAssert(cs.size == 3)
        for (i, (y, x)) in ds.indexed.asSwiftSequence {
            XCTAssert(yArr[i] == y)
            XCTAssert(xArr[i] == x)
        }
    }
    
    func testConcatenate() {
        let xArr = ["alice", "bob", "catherine", "daniel"]
        let yArr = ["alice", "bob", "catherine", "daniel"]
        let zArr = xArr + yArr
        
        let xs = TestableIterable(xArr)
        let ys = TestableIterable(yArr)
        
        
        let bs = xs.concatenated(with: ys)
        XCTAssert(bs.toArray() == zArr)
        
        let cs = xs.concatenate(ys)
        XCTAssert(cs.toArray() == zArr)
        
        let ds = xs ++ ys
        XCTAssert(ds.toArray() == zArr)
    }
    
    
    func testInterleave() {
        let xs = TestableIterable([1, 3, 5, 7])
        let ys = TestableIterable([2, 4, 6])
        let zs = xs.interleave(ys)
        XCTAssert(zs.toArray() == [1, 2, 3, 4, 5, 6, 7])
    }
    
    func testPrepend() {
        let xArr = ["alice", "bob", "catherine", "daniel"]
        let expectedARr = ["zapfino"] + xArr
        
        let xs = TestableIterable(xArr)
        
        let bs = "zapfino" +| xs
        XCTAssert(bs.toArray() == expectedARr)
        
        let cs = xs.prepend("zapfino")
        XCTAssert(cs.toArray() == expectedARr)
        
        let ds = xs.prepended(with: "zapfino")
        XCTAssert(ds.toArray() == expectedARr)
    }
    
    func testAppend() {
        let xArr = ["alice", "bob", "catherine", "daniel"]
        let expectedArr = xArr + ["zapfino"]
        
        let xs = TestableIterable(xArr)
        
        let bs = xs |+ "zapfino"
        XCTAssert(bs.toArray() == expectedArr)
        
        let cs = xs.append("zapfino")
        XCTAssert(cs.toArray() == expectedArr)
        
        let ds = xs.appended(with: "zapfino")
        XCTAssert(ds.toArray() == expectedArr)
    }
    
    func testInsert() {
        
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        
        // A regular insert
        let bs = xs.with(element: "zapfino", insertedAt: 2)
        XCTAssert(bs.toArray() == ["alice", "bob", "zapfino", "catherine", "daniel"])
        
        // Insert at the front
        let cs = xs.with(element: "zapfino", insertedAt: 0)
        XCTAssert(cs.toArray() == ["zapfino", "alice", "bob", "catherine", "daniel"])

        // Insert at the end
        let ds = xs.with(element: "zapfino", insertedAt: xs.size)
        XCTAssert(ds.toArray() == ["alice", "bob", "catherine", "daniel", "zapfino"])

        // Insert into an empty iterator
        let emptyIterable = TestableIterable<String>([])
        let es = emptyIterable.with(element: "zapfino", insertedAt: 0)
        XCTAssert(es.toArray() == ["zapfino"])
        
        // Test insert shorthand
        let fs = xs.insert("zapfino", 2)
        XCTAssert(fs.toArray() == ["alice", "bob", "zapfino", "catherine", "daniel"])
    }
    
    func testHead() {
        // Head of a normal iterable
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.head! == "alice")
        
        // Head of an iterable with just one element
        let ys = TestableIterable(["alice"])
        XCTAssert(ys.head! == "alice")
        
        // Head of an empty iterable
        let zs = TestableIterable<String>([])
        XCTAssert(zs.head == nil)
    }
    
    func testTail() {
        // Tail of a normal iterable
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        let xsTail = xs.tail
        XCTAssert(xsTail.toArray() == ["bob", "catherine", "daniel"])
        
        // Tail of an iterable with just one element
        let ys = TestableIterable(["alice"])
        let ysTail = ys.tail
        XCTAssert(ysTail.toArray() == [])
        
        // Tail of an empty iterable
        let zs = TestableIterable<String>([])
        let zsTail = zs.tail
        XCTAssert(zsTail.toArray() == [])
    }
    
    func testFore() {
        // Fore of a normal iterable
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        let xsFore = xs.fore
        XCTAssert(xsFore.toArray() == ["alice", "bob", "catherine"])
        
        // Fore of an iterable with just one element
        let ys = TestableIterable(["alice"])
        let ysFore = ys.fore
        XCTAssert(ysFore.toArray() == [])
        
        // Fore of an empty iterable
        let zs = TestableIterable<String>([])
        let zsFore = zs.fore
        XCTAssert(zsFore.toArray() == [])
    }
    
    func testLast() {
        // Last of a normal iterable
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.last! == "daniel")
        
        // Last of an iterable with just one element
        let ys = TestableIterable(["daniel"])
        XCTAssert(ys.last! == "daniel")
        
        // Last of an empty iterable
        let zs = TestableIterable<String>([])
        XCTAssert(zs.last == nil)
    }
    
    func testTakeFirst() {
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.take(first: 0).toArray() == [])
        XCTAssert(xs.take(first: 1).toArray() == ["alice"])
        XCTAssert(xs.take(first: 2).toArray() == ["alice", "bob"])
        XCTAssert(xs.take(first: 3).toArray() == ["alice", "bob", "catherine"])
        XCTAssert(xs.take(first: 4).toArray() == ["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.take(first: 5).toArray() == ["alice", "bob", "catherine", "daniel"])
    }

    func testTakeTo() {
        // Test an iterable with some elements
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.take(to: {s in s.count >= 6}).toArray() == ["alice", "bob", "catherine"])
        XCTAssert(xs.take(to: {s in s.count >= 10}).toArray() == ["alice", "bob", "catherine", "daniel"])
        
        // Test an empty iterable
        let ys = TestableIterable<String>([])
        XCTAssert(ys.take(to: {s in s.count >= 6}).toArray() == [])
    }
    
    func testTakeWhile() {
        // Test an iterable with some elements
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.take(while: {$0.count >= 6}).toArray() == ["alice", "bob"])
        XCTAssert(xs.take(while: {s in s.count >= 10}).toArray() == ["alice", "bob", "catherine", "daniel"])
        
        // Test an empty iterable
        let ys = TestableIterable<String>([])
        XCTAssert(ys.take(while: {s in s.count >= 6}).toArray() == [])
    }

    func testTakeUntil() {
        // Test an iterable with some elements
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.take(until: {s in s.count < 6}).toArray() == ["alice", "bob"])
        XCTAssert(xs.take(until: {s in s.count < 10}).toArray() == ["alice", "bob", "catherine", "daniel"])
        
        // Test an empty iterable
        let ys = TestableIterable<String>([])
        XCTAssert(ys.take(until: {s in s.count >= 6}).toArray() == [])
    }
    
    func testDropFirst() {
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.drop(first: 0).toArray() == ["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.drop(first: 1).toArray() == ["bob", "catherine", "daniel"])
        XCTAssert(xs.drop(first: 2).toArray() == ["catherine", "daniel"])
        XCTAssert(xs.drop(first: 3).toArray() == ["daniel"])
        XCTAssert(xs.drop(first: 4).toArray() == [])
        XCTAssert(xs.drop(first: 5).toArray() == [])
    }
    
    func testDropTo() {
        // Test an iterable with some elements
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.drop(to: {s in s.count >= 6}).toArray() == ["daniel"])
        XCTAssert(xs.drop(to: {s in s.count >= 10}).toArray() == [])
        
        // Test an empty iterable
        let ys = TestableIterable<String>([])
        XCTAssert(ys.drop(to: {s in s.count >= 6}).toArray() == [])
    }
    
    func testDropWhile() {
        // Test an iterable with some elements
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.drop(while: {s in s.count < 6}).toArray() == ["catherine", "daniel"])
        XCTAssert(xs.drop(while: {s in s.count < 10}).toArray() == [])
        
        // Test an empty iterable
        let ys = TestableIterable<String>([])
        XCTAssert(ys.drop(while: {s in s.count < 6}).toArray() == [])
    }

    func testDropUntil() {
        // Test an iterable with some elements
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel"])
        XCTAssert(xs.drop(until: {s in s.count >= 6}).toArray() == ["catherine", "daniel"])
        XCTAssert(xs.drop(until: {s in s.count >= 10}).toArray() == [])
        
        // Test an empty iterable
        let ys = TestableIterable<String>([])
        XCTAssert(ys.drop(until: {s in s.count >= 6}).toArray() == [])
    }
    
    func testSlice() {
        let xs = TestableIterable(["alice", "bob", "catherine", "daniel", "emily", "frank"])

        let bs = xs.slice(from: 0, to: 3)
        XCTAssert(bs.toArray() == ["alice", "bob", "catherine", "daniel"])

        let cs = xs.slice(from: 0, until: 4)
        XCTAssert(cs.toArray() == ["alice", "bob", "catherine", "daniel"])
        
        let ds = xs.slice(from: 2, to: 3)
        XCTAssert(ds.toArray() == ["catherine", "daniel"])

        let es = xs.slice(from: 2, until: 4)
        XCTAssert(es.toArray() == ["catherine", "daniel"])
        
        // Corner cases
        let fs = xs.slice(from: -3, until: 9)
        XCTAssert(fs.toArray() == xs.toArray())
    }
    
    
    func testRepeated() {
        let xs = TestableIterable(["alice", "bob", "catherine"])
        
        let ys = xs.repeated(3)
        XCTAssert(ys.toArray() == [
            "alice", "bob", "catherine",
            "alice", "bob", "catherine",
            "alice", "bob", "catherine"
        ])
        
        let zs = xs.repeated(0)
        XCTAssert(zs.toArray() == [])
    }
    
    /// - TODO: How to make this test more valid?
    func testCycled() {
        let xArr = ["alice", "bob", "catherine"]
        let xs = TestableIterable(xArr)
        let ys = xs.cycled.take(first: 30)
        for (i, y) in ys.indexed.asSwiftSequence {
            XCTAssert(y == xArr[i % 3])
        }
    }
    
    
    func testSlidingWindow() {
        let xs = TestableIterable([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

        func normalCase() {
            let ys = xs.slidingWindows(3, 1)
            XCTAssert(ys.size == 9)
            let yArr = ys.toArray()
            XCTAssert(yArr[0].toArray() == [0, 1, 2])
            XCTAssert(yArr[1].toArray() == [1, 2, 3])
            XCTAssert(yArr[2].toArray() == [2, 3, 4])
            XCTAssert(yArr[3].toArray() == [3, 4, 5])
            XCTAssert(yArr[4].toArray() == [4, 5, 6])
            XCTAssert(yArr[5].toArray() == [5, 6, 7])
            XCTAssert(yArr[6].toArray() == [6, 7, 8])
            XCTAssert(yArr[7].toArray() == [7, 8, 9])
            XCTAssert(yArr[8].toArray() == [8, 9, 10])
        }
        
        func normalCaseStepSize2() {
            let ys = xs.slidingWindows(3, 2)
            XCTAssert(ys.size == 5)
            let yArr = ys.toArray()
            XCTAssert(yArr[0].toArray() == [0, 1, 2])
            XCTAssert(yArr[1].toArray() == [2, 3, 4])
            XCTAssert(yArr[2].toArray() == [4, 5, 6])
            XCTAssert(yArr[3].toArray() == [6, 7, 8])
            XCTAssert(yArr[4].toArray() == [8, 9, 10])
        }

        func emptyOriginalIterable() {
            let empty = TestableIterable([])
            let ys = empty.slidingWindows(3, 1)
            XCTAssert(ys.size == 0)
            for _ in ys.asSwiftSequence {
                // Should not enter here
                XCTAssert(false)
            }
        }
        
        func windowSizeSameAsOriginalIterable() {
            let ys = xs.slidingWindows(xs.size, 2)
            XCTAssert(ys.size == 1)
            XCTAssert(ys.toArray()[0].toArray() == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        }
        
        func windowSizeLargerThanOriginalIterable() {
            let ys = xs.slidingWindows(xs.size + 3, 1)
            XCTAssert(ys.size == 0)
            
        }
        
        normalCase()
        normalCaseStepSize2()
        emptyOriginalIterable()
        windowSizeSameAsOriginalIterable()
        windowSizeLargerThanOriginalIterable()
    }
    
    func testInclusiveSlidingWindows() {
        let xArr = ["a", "b", "c", "d", "e", "f"]
        let xs = TestableIterable(xArr)
        
        func normalCase() {
            let ys = xs.inclusiveSlidingWindows(4, 1)
            let yArr = ys.toArray()
            XCTAssert(yArr.count == 3)
            XCTAssert(yArr[0].toArray() == ["a", "b", "c", "d"])
            XCTAssert(yArr[1].toArray() == ["b", "c", "d", "e"])
            XCTAssert(yArr[2].toArray() == ["c", "d", "e", "f"])
        }
        
        func normalCaseStep2() {
            let ys = xs.inclusiveSlidingWindows(3, 2)
            let yArr = ys.toArray()
            XCTAssert(yArr.count == 3)
            XCTAssert(yArr[0].toArray() == ["a", "b", "c"])
            XCTAssert(yArr[1].toArray() == ["c", "d", "e"])
            XCTAssert(yArr[2].toArray() == ["e", "f"])
        }
        
        func windowSizeSameAsOriginalIterable() {
            let ys = xs.inclusiveSlidingWindows(6, 1)
            let yArr = ys.toArray()
            XCTAssert(yArr.count == 1)
            XCTAssert(yArr[0].toArray() == xArr)
        }
        
        func windowSizeIsLargerThanOriginalIterable() {
            let ys = xs.inclusiveSlidingWindows(7, 1)
            let yArr = ys.toArray()
            XCTAssert(yArr.count == 1)
            XCTAssert(yArr[0].toArray() == xArr)
        }
        
        normalCase()
        normalCaseStep2()
        windowSizeSameAsOriginalIterable()
        windowSizeIsLargerThanOriginalIterable()
        
        
        
    }
    
    func testGrouped() {
        
    }
    
    func testSlidingPairs() {
        func regularCase() {
            let xs = TestableIterable(["a", "b", "c", "d"])
            let pairs = xs.slidingPairs
            XCTAssert(pairs.size == 3)
            let pairArr = pairs.toArray()
            XCTAssert(pairArr[0] == ("a", "b"))
            XCTAssert(pairArr[1] == ("b", "c"))
            XCTAssert(pairArr[2] == ("c", "d"))
        }
        regularCase()

        
        func onlyOneElement() {
            let xs = TestableIterable(["a"])
            let pairs = xs.slidingPairs
            XCTAssert(pairs.size == 0)
            for _ in pairs.asSwiftSequence {
                XCTAssert(false)
            }
        }
        onlyOneElement()

        func zeroElements() {
            let xs = TestableIterable([])
            let pairs = xs.slidingPairs
            XCTAssert(pairs.size == 0)
            for _ in pairs.asSwiftSequence {
                XCTAssert(false)
            }
        }
        zeroElements()
    }
    
    func testSlidingPairsWith() {
        func regularCase() {
            let xs = TestableIterable(["a", "b", "c", "d"])
            let pairs = xs.slidingPairs(with: {"\($0)-\($1)"})
            XCTAssert(pairs.size == 3)
            let pairArr = pairs.toArray()
            XCTAssert(pairArr[0] == "a-b")
            XCTAssert(pairArr[1] == "b-c")
            XCTAssert(pairArr[2] == "c-d")
        }
        regularCase()
        
        
        func onlyOneElement() {
            let xs = TestableIterable(["a"])
            let pairs = xs.slidingPairs(with: {"\($0)-\($1)"})
            XCTAssert(pairs.size == 0)
            for _ in pairs.asSwiftSequence {
                XCTAssert(false)
            }
        }
        onlyOneElement()
        
        func zeroElements() {
            let xs = TestableIterable([])
            let pairs = xs.slidingPairs(with: {"\($0)-\($1)"})
            XCTAssert(pairs.size == 0)
            for _ in pairs.asSwiftSequence {
                XCTAssert(false)
            }
        }
        zeroElements()
    }
    
    func testSlidingTriples() {
        
    }
    
    func testPairChunks() {
        
    }
    
    func testTripleChunks() {
        
    }
    

    func testTo() {
        let xs: TestableIterable<String> = TestableIterable(["alice", "bob", "catherine", "daniel"])
        let arr: ArraySeq<String> = xs.to(ArraySeq.newBuilder())
        XCTAssert(xs.toArray() == arr.toArray())
    }
    
    func testCreateIterableFromIterator() {
        let iterator = TestableIterator(["a", "b"])
        let iterable = IterableOf(iterator)
        XCTAssert(iterable.toArray() == ["a", "b"])
    }

}
