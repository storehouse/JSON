JSON
========

### What is it? ###

JSON is a simple Swift library for working with JSON data. It can be initialized with either a string, NSData, or a JSON object returned by NSJSONSerialization. It provides a lightweight fast API that removes the need to cast untyped values typically returned by NSJSONSerialization.

### Requirements ###
* Swift 2+
* Foundation

### Usage ###

At the core of this library is the following enum, which represents a JSON tree (as dictated by the [JSON spec](http://www.json.org)) as a Swift value type:

```swift
enum JSON {
    case Number(Double)
    case String(Swift.String)
    case Boolean(Bool)
    case Array([JSON])
    case Object([Swift.String:JSON])
    case Null
}
```

##### Create a JSON value #####

```swift
let jsonObj = ... // a JSON object that NSJSONSerialization.JSONObjectWithData returned
let json = JSON(NSJSONObject: jsonObj) // this converts your [NSObject : AnyObject] to the JSON value type
```

You can also create a JSON value directly from raw JSON data (as a String or NSData):

```swift
let json = JSON(string: ...)
let json = JSON(data: ...)
```

*Note*: The string/data initializers are failable and will return nil if JSON parsing fails.

##### Working with JSON values #####

There are value accessors available for the core JSON value types.

```
array -> [JSON]?
object -> [String : JSON]?
string -> String?
number -> Double?
boolean -> Bool?
```

Use subscripting to access children of a JSON value. Every child value is represented by the type `JSON?`, which also contains the underlying value itself. For example:
```swift
let j = JSON(...)

let person = j["person"] // returns JSON?

if let person = person {
  let name = person["name"]?.string // subscript returns JSON?, .string returns String?
  let website = person["website"]?.URL // NSURL? converted from String, if valid/present
  // etc
}
```

There are also convenience accessors for `NSURL?` and `NSDate?` to make it easier to work with common JSON responses.

```swift
let urlVal = j["url"] // JSON?
let urlString = urlVal.string // this is valid, since 'url' is encoded as a JSON string
let url = urlVal.URL // this is also valid and returns an NSURL

let dateVal = j["created_at"] // JSON?
let dateNum = dateVal.number // valid, assuming 'created_at' is a JSON number
let date = dateVal.date // also valid and assumes that created_at is a unix timestamp encoded as a JSON number
```

##### JSONEncodable / JSONDecodable #####

We also expose protocols that allow you to add custom encoding and decoding between any arbitrary type and a JSON value. For example, check out how we implement this for `CGRect`:
```swift
extension CGRect: JSONDecodable {
    public init?(json: JSON?) {
        guard let origin = CGPoint(json: json?["origin"]) else { return nil }
        guard let size = CGSize(json: json?["size"]) else { return nil }
        self.origin = origin
        self.size = size
    }
}

extension CGRect: JSONEncodable {
    public var json: JSON {
        var j = JSON.Object([:])
        j["origin"] = origin.json
        j["size"] = size.json
        return j
    }
}
```

Note that we can directly initialize a CGPoint and CGSize from JSON values and call .json on both types - this is because both CGPoint and CGSize also declare their own conformance to JSONDecodable and JSONEncodable:

```swift
extension CGSize: JSONDecodable {
    public init?(json: JSON?) {
        guard let width = json?["width"]?.number else { return nil }
        guard let height = json?["height"]?.number else { return nil }
        self.init(width: width, height: height)
    }
}

extension CGSize: JSONEncodable {
    public var json: JSON {
        var j = JSON.Object([:])
        j["width"] = width.json
        j["height"] = height.json
        return j
    }
}

extension CGPoint: JSONDecodable {
    public init?(json: JSON?) {
        guard let x = json?["x"]?.number else { return nil }
        guard let y = json?["y"]?.number else { return nil }
        self.init(x: x, y: y)
    }
}

extension CGPoint: JSONEncodable {
    public var json: JSON {
        var j = JSON.Object([:])
        j["x"] = x.json
        j["y"] = y.json
        return j
    }
}
```

This lets us do things like:
```swift
let rect = CGRect(x: 1.0, y: 2.0, width: 100.0, height: 150.0)
let json = rect.json // json is now a JSON value type

let rect2 = CGRect(json: j["rect"]) // where 'j' is json from the server, for example
```

This is helpful for composing new JSON values from your existing types and classes.

Please see [JSONExtensions.swift](JSON/JSONExtensions.swift) for an update to date list of types support JSONEncodable/JSONDecodable out of the box.

##### Generating a JSON string #####

We also support serializing a JSON value to a raw JSON string via the `formattedJSON` property. This uses NSJSONSerialization internally.

```swift
let j = JSON(...)
NSLog("\(j.formattedJSON)")
```

### License ###
```
Copyright (c) 2016, Storehouse Media Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
