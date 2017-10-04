//
//  BuilderTests.swift
//  LazyTests
//
//  Created by Yuhuan Jiang on 10/4/17.
//

import XCTest
@testable import Lazy


class TestableArrayBuilder<I>: Builder {
    typealias In = I
    typealias Out = [I]
    
    var arr: [I]
    
    init() {
        arr = Array<I>()
    }
    
    func add(_ input: I) {
        arr.append(input)
    }
    
    func result() -> [I] {
        return arr
    }
}


class BuilderTests: XCTestCase {

    func testBuilder() {
        var builder = TestableArrayBuilder<String>()
        builder.add("alice")
        builder.add("bob")
        builder.addAll(ArraySeq.of(elements: "catherine", "daniel"))
        let result = builder.result()
        XCTAssert(result == ["alice", "bob", "catherine", "daniel"])
    }

}
