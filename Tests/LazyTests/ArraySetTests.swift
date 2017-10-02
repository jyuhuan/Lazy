//
//  ArraySetTests.swift
//  LazyTests
//
//  Created by Yuhuan Jiang on 10/1/17.
//

import XCTest
@testable import Lazy

class ArraySetTests: XCTestCase {

    func testSetFilter() {
        let set = ArraySet<String>(elements: "dog", "kitten", "pig")
        let filteredSet = set.filtered { name in name.count <= 3 }
        XCTAssert(filteredSet.has("dog"))
        XCTAssert(filteredSet.hasNot("kitten"))
        XCTAssert(filteredSet.has("pig"))
    }

}
