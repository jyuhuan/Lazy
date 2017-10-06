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
        for (i, x) in xs.indexed.swiftSequence {
            XCTAssert(arr[i] == x)
        }
    }
    
    func testZip() {
        let xArr = ["alice", "bob", "catherine", "daniel"]
        let xs = TestableIterable(xArr)
        let yArr = [5, 3, 9, 6]
        let ys = TestableIterable(yArr)
        
        let bs = xs.zipped(with: ys)
        for (i, (x, y)) in bs.indexed.swiftSequence {
            XCTAssert(xArr[i] == x)
            XCTAssert(yArr[i] == y)
        }
        
        let cs = xs.zip(ys)
        for (i, (x, y)) in cs.indexed.swiftSequence {
            XCTAssert(xArr[i] == x)
            XCTAssert(yArr[i] == y)
        }
        
        let ds = xs ⛙ ys
        for (i, (x, y)) in ds.indexed.swiftSequence {
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
        for (i, (x, y)) in cs.indexed.swiftSequence {
            XCTAssert(xArr[i] == x)
            XCTAssert(yArr[i] == y)
        }
        
        let ds = ys ⛙ xs
        XCTAssert(cs.size == 3)
        for (i, (y, x)) in ds.indexed.swiftSequence {
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
        let yArr = ["zapfino"] + xArr
        
        let xs = TestableIterable(xArr)
        let ys = "zapfino" +| xs
        XCTAssert(ys.toArray() == yArr)
    }
    
    func testAppend() {
        let xArr = ["alice", "bob", "catherine", "daniel"]
        let yArr = xArr + ["zapfino"]
        
        let xs = TestableIterable(xArr)
        let ys = xs |+ "zapfino"
        XCTAssert(ys.toArray() == yArr)
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
