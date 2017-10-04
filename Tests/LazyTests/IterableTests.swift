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

}
