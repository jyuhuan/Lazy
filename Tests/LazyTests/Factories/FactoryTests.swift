//
//  FactoryTest.swift
//  LazyTests
//
//  Created by Yuhuan Jiang on 10/4/17.
//

import XCTest
@testable import Lazy

class TestableArrayFactory<X>: Factory {
    typealias In = X
    typealias Out = Array<X>
    typealias NewBuilder = TestableArrayBuilder<X>
    
    static func newBuilder() -> TestableArrayBuilder<X> {
        return TestableArrayBuilder()
    }
}

class FactoryTests: XCTestCase {

    func testEmpty() {
        let arr = TestableArrayFactory<String>.empty()
        XCTAssert(arr.count == 0)
    }
    
    func testOf() {
        let arr = TestableArrayFactory.of(elements: "a", "b", "c")
        XCTAssert(arr == ["a", "b", "c"])
    }
    
    func testFrom() {
        let arr = TestableArrayFactory.from(iterable: ArraySeq(elements: ["a", "b" ,"c"]))
        XCTAssert(arr == ["a", "b", "c"])
    }

}
