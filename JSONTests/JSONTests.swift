import XCTest
@testable import JSON


class JSONTests: XCTestCase {
    
    let sampleJSON: AnyObject = {
        let path = NSBundle(forClass: JSONTests.self).URLForResource("sample", withExtension: "json")!
        let data = NSData(contentsOfURL: path)!
        return try! NSJSONSerialization.JSONObjectWithData(data, options: [])
    }()
    
    func testJSONTree() {
        let j = JSON(NSJSONObject: sampleJSON)
        XCTAssert(j.object != nil)
        
        let ID: JSON? = j["ID"]
        XCTAssert(ID != nil)
        XCTAssert(ID!.number != nil)
        XCTAssert(ID!.number! == 719365)
        
        let name: JSON? = j["name"]
        XCTAssert(name != nil)
        XCTAssert(name!.string != nil)
        XCTAssert(name!.string! == "Example JSON")
        
        let attributes: JSON? = j["attributes"]
        XCTAssert(attributes != nil)
        XCTAssert(attributes!.object != nil)
        XCTAssert(attributes!.object!.count == 3)
        
        let colors: JSON? = attributes!.object!["favorite_colors"]
        XCTAssert(colors != nil)
        XCTAssert(colors!.array != nil)
        XCTAssert(colors!.array!.count == 2)
        
        let firstColor: JSON? = colors![0]
        XCTAssert(firstColor != nil)
        XCTAssert(firstColor!.object != nil)
        XCTAssert(firstColor!.object!["red"]!.number! == 0.1)
        XCTAssert(firstColor!.object!["green"]!.number! == 0.2)
        XCTAssert(firstColor!.object!["blue"]!.number! == 0.3)
        XCTAssert(firstColor!.object!["alpha"]!.number! == 0.5)
        
        let secondColor: JSON? = colors![1]
        XCTAssert(secondColor != nil)
        XCTAssert(secondColor!.object != nil)
        XCTAssert(secondColor!.object!["red"]!.number! == 0.3)
        XCTAssert(secondColor!.object!["green"]!.number! == 0.6)
        XCTAssert(secondColor!.object!["blue"]!.number! == 0.9)
        XCTAssert(secondColor!.object!["alpha"]!.number! == 1.0)
        
        let funny: JSON? = attributes!.object!["funny"]
        XCTAssert(funny != nil)
        XCTAssert(funny!.boolean != nil)
        XCTAssert(funny!.boolean! == true)
        
        let something: JSON? = attributes!.object!["something"]
        XCTAssert(something != nil)
        
        let fake: JSON? = j["fake"]
        XCTAssert(fake == nil)
    }
    
    func testTypes() {
        let num = JSON.Number(1.0)
        XCTAssertEqual(num.number,1.0)
        XCTAssertNotNil(num.number)
        XCTAssertNil(num.string)
        XCTAssertNil(num.boolean)
        XCTAssertNil(num.array)
        XCTAssertNil(num.object)
        
        let str = JSON.String("Foo")
        XCTAssertEqual(str.string,"Foo")
        XCTAssertNil(str.number)
        XCTAssertNotNil(str.string)
        XCTAssertNil(str.boolean)
        XCTAssertNil(str.array)
        XCTAssertNil(str.object)
        
        let b = JSON.Boolean(true)
        XCTAssertEqual(b.boolean,true)
        XCTAssertNil(b.number)
        XCTAssertNil(b.string)
        XCTAssertNotNil(b.boolean)
        XCTAssertNil(b.array)
        XCTAssertNil(b.object)
        
        let a = JSON.Array([])
        XCTAssertEqual(a.array!,[])
        XCTAssertNil(a.number)
        XCTAssertNil(a.string)
        XCTAssertNil(a.boolean)
        XCTAssertNotNil(a.array)
        XCTAssertNil(a.object)
        
        let obj = JSON.Object([:])
        XCTAssertEqual(obj.object!,[:])
        XCTAssertNil(obj.number)
        XCTAssertNil(obj.string)
        XCTAssertNil(obj.boolean)
        XCTAssertNil(obj.array)
        XCTAssertNotNil(obj.object)
        
        let n = JSON.Null
        XCTAssertNil(n.number)
        XCTAssertNil(n.string)
        XCTAssertNil(n.boolean)
        XCTAssertNil(n.array)
        XCTAssertNil(n.object)
    }
    
    func testEquality() {
        let j1 = JSON(NSJSONObject: sampleJSON)
        let j2 = JSON(NSJSONObject: sampleJSON)
        XCTAssert(j1 == j2)
    }
    
    func testFormattedJSON() {
        let j1 = JSON(NSJSONObject: sampleJSON)
        let jsonString = j1.formattedJSON
        XCTAssert(jsonString.characters.count > 0)
        
        let j2 = JSON(string: jsonString)
        XCTAssert(j2 != nil)
        XCTAssert(j1 == j2!)
    }
    
}
