//
//  IterableTests.swift
//  LazyTests
//
//  Created by Yuhuan Jiang on 10/2/17.
//

import XCTest
@testable import Lazy

class IterableTests: XCTestCase {

    func testFlatMappedBy() {
        let xs = ArraySeq.of(elements: "alice", "bob", "catherine")
        let ys = xs.flatMapped(by: {s in ArraySeq.of(elements: "a", "b", "c")})
        let arr = ys.toArray()
    }

    func testFlatMap() {
        let xs = ArraySeq.of(elements: "alice", "bob", "catherine")
        let ys = xs.flatMap{s in ArraySeq.of(elements: "a", "b", "c")}
        let arr = ys.toArray()
    }

}