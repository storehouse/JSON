/*

Copyright (c) 2016, Storehouse
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

* Neither the name of JSON nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

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

*/

import Foundation
import CoreGraphics


// MARK: Double

extension Double : JSONDecodable {
    public init?(json: JSON?) {
        guard let double = json?.number else { return nil }
        self = double
    }
}

extension Double : JSONEncodable {
    public var json: JSON {
        return .Number(self)
    }
}

// MARK: Bool

extension Bool : JSONDecodable {
    public init?(json: JSON?) {
        guard let b = json?.boolean else { return nil }
        self = b
    }
}

extension Bool : JSONEncodable {
    public var json: JSON {
        return .Boolean(self)
    }
}

// MARK: String

extension String : JSONDecodable {
    public init?(json: JSON?) {
        guard let str = json?.string else { return nil }
        self = str
    }
}

extension String : JSONEncodable {
    public var json: JSON {
        return .String(self)
    }
}

// MARK: Int

extension Int : JSONDecodable {
    public init?(json: JSON?) {
        guard let d = json?.number else { return nil }
        self = Int(d)
    }
}

extension Int : JSONEncodable {
    public var json: JSON {
        return Double(self).json
    }
}

// MARK: CGFloat

extension CGFloat : JSONDecodable {
    public init?(json: JSON?) {
        guard let n = json?.number else { return nil }
        self.init(n)
    }
}

extension CGFloat : JSONEncodable {
    public var json: JSON {
        return .Number(Double(self))
    }
}

// MARK: CGSize

extension CGSize : JSONDecodable {
    public init?(json: JSON?) {
        guard let width = json?["width"]?.number else { return nil }
        guard let height = json?["height"]?.number else { return nil }
        self.init(width: width, height: height)
    }
}

extension CGSize : JSONEncodable {
    public var json: JSON {
        var j = JSON.Object([:])
        j["width"] = width.json
        j["height"] = height.json
        return j
    }
}

// MARK: CGPoint

extension CGPoint : JSONDecodable {
    public init?(json: JSON?) {
        guard let x = json?["x"]?.number else { return nil }
        guard let y = json?["y"]?.number else { return nil }
        self.init(x: x, y: y)
    }
}

extension CGPoint : JSONEncodable {
    public var json: JSON {
        var j = JSON.Object([:])
        j["x"] = x.json
        j["y"] = y.json
        return j
    }
}

// MARK: CGRect

extension CGRect : JSONDecodable {
    public init?(json: JSON?) {
        guard let origin = CGPoint(json: json?["origin"]) else { return nil }
        guard let size = CGSize(json: json?["size"]) else { return nil }
        self.origin = origin
        self.size = size
    }
}

extension CGRect : JSONEncodable {
    public var json: JSON {
        var j = JSON.Object([:])
        j["origin"] = origin.json
        j["size"] = size.json
        return j
    }
}

// MARK: Array

extension Array : JSONEncodable {
    public var json: JSON {
        var result: [JSON] = []
        for el in self {
            guard let convertible = el as? JSONEncodable else { fatalError() }
            result.append(convertible.json)
        }
        return .Array(result)
    }
}

extension Array : JSONDecodable {
    public init?(json: JSON?) {
        guard let array = json?.array else { return nil }
        guard let type = Element.self as? JSONDecodable.Type else { return nil }
        self.init()
        for j in array {
            guard let val = type.init(json: j) as? Element else { return nil }
            append(val)
        }
    }
}

// MARK: Dictionary

extension Dictionary : JSONEncodable {
    public var json: JSON {
        var result: [String: JSON] = [:]
        for (key, val) in self {
            guard let key = key as? String else { fatalError("Keys must be of type 'String'") }
            guard let val = val as? JSONEncodable else { fatalError("Values must conform to 'JSONEncodable'") }
            result[key] = val.json
        }
        return JSON.Object(result)
    }
}

extension Dictionary : JSONDecodable {
    public init?(json: JSON?) {
        guard let dict = json?.object else { return nil }
        guard Key.self == String.self else { fatalError("Dictionary keys must be of type 'String' to decode from JSON") }
        guard let valueType = Value.self as? JSONDecodable.Type else { fatalError("Dictionary values must be a concrete implementation of 'JSONDecodable' to decode from JSON") }
        self.init()
        for (key, val) in dict {
            guard let key = key as? Key else { return nil }
            guard let val = valueType.init(json: val) as? Value else { return nil }
            self[key] = val
        }
    }
}

// MARK: NSURL

extension NSURL : JSONEncodable {
    public var json: JSON {
        return .String(absoluteString)
    }
}

extension JSON {
    // we cannot make NSURL conform to JSONDecodable because it's a class and we can't add an initializer in an extension
    /// The JSON string value encoded as an NSURL, or nil if not a JSON string.
    var URL: NSURL? {
        guard let s = string else { return nil }
        return NSURL(string: s)
    }
}

// MARK: NSDate

extension NSDate : JSONEncodable {
    public var json: JSON {
        return .Number(timeIntervalSince1970)
    }
}

extension JSON {
    // we cannot make NSDate conform to JSONEncodable because it's a class and we can't add an initializer in an extension
    /// The JSON number value encoded as an NSDate, or nil if not a JSON number.
    /// - Note: The conversion assumes that the JSON number value is a date represented as a UNIX timestamp.
    var date: NSDate? {
        guard let n = number else { return nil }
        return NSDate(timeIntervalSince1970: n)
    }
}
