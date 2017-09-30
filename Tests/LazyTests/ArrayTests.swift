import XCTest
@testable import Lazy

class ArrayTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateEmptyArray() {
        let arr = Lazy.Array<String>.empty()
        XCTAssert(arr.count == 0)
    }
    
    func testCreateArrayOutOfElements() {
        let a = Array.of(elements: "a", "b")
        XCTAssert(a.count == 2)
    }
    
    func testCreateArrayByFilling() {
        let b = Array.fill(5){i in return i}
        XCTAssert(b.count == 5)
    }
    
}

