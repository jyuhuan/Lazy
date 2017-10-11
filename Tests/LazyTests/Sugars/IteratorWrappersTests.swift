//
//  IteratorWrappersTests.swift
//  LazyTests
//
//  Created by Yuhuan Jiang on 10/10/17.
//

import XCTest
@testable import Lazy

class IteratorWrappersTests: XCTestCase {

    func testNonProactiveIteratorWrapper() {
        
        let arr = [1, 2, 3, 4]
        let iter = NonProactiveIterator(arr.makeIterator())

        var result = Array<Int>()
        
        while iter.hasNext {
            let next = iter.next()
            result.append(next)
        }
        
        XCTAssert(arr == result)
        
    }

}
