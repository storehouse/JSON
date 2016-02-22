import XCTest

class EncodingTests: XCTestCase {
    
    func testDouble() {
        let initialValue: Double = 4.5
        let json = initialValue.json
        guard let finalValue = Double(json: json) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
        
        let incorrect = String(json: json)
        XCTAssertNil(incorrect)
    }
    
    func testString() {
        let initialValue = "Lorem Ipsum"
        let json = initialValue.json
        guard let finalValue = String(json: json) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testBool() {
        let initialValue = true
        let json = initialValue.json
        guard let finalValue = Bool(json: json) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testInt() {
        let initialValue = 42
        let json = initialValue.json
        guard let finalValue = Int(json: json) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testCGPoint() {
        let initialValue = CGPoint(x: 2.0, y: 8.123)
        let json = initialValue.json
        guard let finalValue = CGPoint(json: json) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testCGSize() {
        let initialValue = CGSize(width: 2.0, height: 8.123)
        let json = initialValue.json
        guard let finalValue = CGSize(json: json) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testCGRect() {
        let initialValue = CGRect(x: 1.0, y: 2.0, width: 3.0, height: 4.0)
        let json = initialValue.json
        guard let finalValue = CGRect(json: json) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testArray() {
        let rect1 = CGRect(x: 1.0, y: 2.0, width: 3.0, height: 4.0)
        let rect2 = CGRect(x: 4.0, y: 3.0, width: 2.0, height: 1.0)
        let initialValue = [rect1, rect2]
        let json = initialValue.json
        guard let finalValue: [CGRect] = Array(json: json) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testDictionary() {
        let initialValue = ["one": 1.0, "two": 2.0]
        let json = initialValue.json
        guard let finalValue: [String:Double] = Dictionary(json: json) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testNSURL() {
        let initialValue = NSURL(string: "https://storehouse.co")!
        let json = initialValue.json
        guard let string = json.string else { XCTFail(); return }
        guard let finalValue = NSURL(string: string) else { XCTFail(); return }
        XCTAssertEqual(initialValue, finalValue)
    }
    
    func testNSDate() {
        let initialValue = NSDate(timeIntervalSince1970: 1455666528)
        let json = initialValue.json
        guard let number = json.number else { XCTFail(); return }
        let finalValue = NSDate(timeIntervalSince1970: number)
        XCTAssertEqual(initialValue, finalValue)
    }
}
