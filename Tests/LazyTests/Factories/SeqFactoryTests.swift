//
//  SeqFactoryTests.swift
//  LazyTests
//
//  Created by Yuhuan Jiang on 10/4/17.
//

import XCTest
@testable import Lazy

class SeqFactoryTests: XCTestCase {

    func testFill() {
        var i = 0
        func generateNumber() -> Int {
            i += 1;
            return i;
        }
        
        let arr = ArraySeq.fill(5, generateNumber())
        XCTAssert(arr.toArray() == [1, 2, 3, 4, 5])
    }
    
    func testTabulate() {
        let arr = ArraySeq.tabulate(5){i in return i * 10}
        assert(arr.count == 5)
        for (i, x) in arr.indexed.asSwiftSequence {
            XCTAssert(x == i * 10)
        }
    }

}
