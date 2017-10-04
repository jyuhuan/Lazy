//
//  DefaultableTests.swift
//  LazyTests
//
//  Created by Yuhuan Jiang on 10/4/17.
//

import XCTest
@testable import Lazy

class DefaultableTests: XCTestCase {

    func defaultValue<T: Defaultable>() -> T {
        return T.defaultValue()
    }
    
    func testDefaultable() {
        let int: Int = defaultValue()
        let string: String = defaultValue()
        
        XCTAssert(int == 0)
        XCTAssert(string == "")
    }

}
