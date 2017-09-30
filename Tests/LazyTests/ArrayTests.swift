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
        let arr = Array.of(elements: "a", "b")
        XCTAssert(arr.count == 2)
    }
    
    func testCreateArrayByFilling() {
        let arr = Array.fill(5, 8)
        XCTAssert(arr.count == 5)
    }
    
    func testCreateArrayByTabulating() {
        let arr = Array.tabulate(5){i in return i * 10}
        XCTAssert(arr.count == 5)
        for (i, x) in arr.indexed() {
            XCTAssert(x == i * 10)
        }
    }
    
}

