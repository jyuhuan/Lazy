//
//  ArrayMapTests.swift
//  LazyTests
//
//  Created by Yuhuan Jiang on 10/1/17.
//

import XCTest
@testable import Lazy

class ArrayMapTests: XCTestCase {
    
    func testCreateEmptyArrayMap() {
    }
    
    func testArrayMapMapped() {
        let animalCounts = ArrayMap<String, Int>(pairs:
            ("dog", 4), ("cat", 10), ("pig", 19)
        )
        let animalAmounts = animalCounts.mapped { (count: Int) -> String in
            return count < 5 ? "too few" : "too many"
        }
        XCTAssert(animalAmounts.valueOf(key: "dog") == "too few",  "wrong!")
        XCTAssert(animalAmounts.valueOf(key: "cat") == "too many", "wrong!")
        XCTAssert(animalAmounts.valueOf(key: "pig") == "too many", "wrong!")
    }
    
}
