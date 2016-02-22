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


/// Recursive structure that represents a JSON tree.
public enum JSON {
    case Number(Double)
    case String(Swift.String)
    case Boolean(Bool)
    case Array([JSON])
    case Object([Swift.String:JSON])
    case Null
}


public extension JSON {
    
    /// Initialize a JSON value from NSData.
    /// - Parameter data: A data object containing JSON data (typically fetched from a server or file).
    /// - Note: returns nil if the data object could not be successfully parsed as JSON.
    public init?(data: NSData) {
        do {
            let obj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            self.init(NSJSONObject: obj)
        } catch {
            return nil
        }
    }
    
    /// Initialize a JSON value from a string containing JSON data.
    /// - Parameter string: A string containing JSON data.
    /// - Note: returns nil if the string could not be successfully parsed as JSON.
    public init?(string: Swift.String) {
        guard let data = string.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
        self.init(data: data)
    }
    
    /// Initialize a JSON value from a JSON object returned by NSJSONSerialization.
    /// - Parameter NSJSONObject: A JSON object returned by NSJSONSerialization.
    /// - SeeAlso: `init?(data:)`
    public init(NSJSONObject: AnyObject) {
        switch NSJSONObject {
        case let number as NSNumber:
            let typeString = NSString(UTF8String: number.objCType)
            guard let type = typeString else { fatalError() } // should not be possible
            if type.isEqualToString("c") {
                self = .Boolean(number.boolValue)
            } else {
                self = .Number(number.doubleValue)
            }
        case let str as Swift.String:
            self = .String(str)
        case let boolean as Bool:
            self = .Boolean(boolean)
        case let array as [AnyObject]:
            self = .Array(array.map {JSON(NSJSONObject: $0)})
        case let dictionary as [NSObject: AnyObject]:
            var d: [Swift.String: JSON] = [:]
            for key in dictionary.keys {
                guard let key = key as? Swift.String else { fatalError("Unexpected key type found in JSON Dictionary") }
                guard let val = dictionary[key] else { fatalError("Error retrieving value from JSON Dictionary") }
                d[key] = JSON(NSJSONObject: val)
            }
            self = .Object(d)
        case _ as NSNull:
            self = .Null
        default:
            fatalError("Unsupported JSON object type")
        }
    }
    
}


public extension JSON { // core JSON-type accessors
    
    public subscript(key: Swift.String) -> JSON? {
        get {
            guard case let .Object(dictionary) = self else { return nil }
            return dictionary[key]
        }
        set {
            guard case var .Object(dictionary) = self else { fatalError("Keyed valued are only supported on objects") }
            dictionary[key] = newValue
            self = .Object(dictionary)
        }
    }
    
    public subscript(index: Int) -> JSON? {
        get {
            guard case let .Array(array) = self else { return nil }
            return array[index]
        }
    }
    
    /// The underlying string value for a JSON string, or nil if it's not a JSON string.
    public var string: Swift.String? {
        switch self {
        case .String(let str):
            return str
        default:
            return nil
        }
    }
    
    /// The underlying number value (as a `Double`) for a JSON number, or nil if it's not a JSON number.
    public var number: Double? {
        switch self {
        case .Number(let num):
            return num
        default:
            return nil
        }
    }
    
    /// The underlying boolean value for a JSON boolean, or nil if it's not a JSON boolean.
    public var boolean: Bool? {
        switch self {
        case .Boolean(let bool):
            return bool
        default:
            return nil
        }
    }
    
    /// The underlying array value for a JSON array, or nil if it's not a JSON array.
    public var array: [JSON]? {
        switch self {
        case .Array(let array):
            return array
        default:
            return nil
        }
    }
    
    /// The underlying dictionary value for a JSON dictionary, or nil if it's not a JSON dictionary.
    public var object: [Swift.String: JSON]? {
        switch self {
        case .Object(let dictionary):
            return dictionary
        default:
            return nil
        }
    }
    
}


extension JSON : Equatable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case (.Number(let num1), .Number(let num2)):
        return num1 == num2
    case (.String(let str1), .String(let str2)):
        return str1 == str2
    case (.Boolean(let b1), .Boolean(let b2)):
        return b1 == b2
    case (.Array(let a1), .Array(let a2)):
        return a1 == a2
    case (.Object(let o1), .Object(let o2)):
        return o1 == o2
    case (.Null, .Null):
        return true
    default:
        return false
    }
}


extension JSON : SequenceType {
    
    public func generate() -> JSONGenerator {
        return JSONGenerator(JSONs: array ?? [])
    }
    
    public struct JSONGenerator: GeneratorType {
        private let JSONs: [JSON]
        private var nextIndex = 0
        private init(JSONs: [JSON]) { self.JSONs = JSONs }
        public mutating func next() -> JSON? {
            guard nextIndex < JSONs.count else { return nil }
            let j = JSONs[nextIndex]
            nextIndex += 1
            return j
        }
    }
    
}


extension JSON : CustomDebugStringConvertible, CustomStringConvertible {
    
    public var debugDescription: Swift.String {
        return formattedOutputString(pretty: true)
    }
    
    public var description: Swift.String {
        return formattedOutputString(pretty: true)
    }
    
    /// The JSON tree formatted as a JSON string.
    /// - SeeAlso: `description` and `debugDescription`.
    public var formattedJSON: Swift.String {
        return formattedOutputString(pretty: false)
    }
    
    private func formattedOutputString(pretty pretty: Bool) -> Swift.String {
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(NSJSONValue, options: pretty ? [.PrettyPrinted] : [])
            guard let string = NSString(data: data, encoding: NSUTF8StringEncoding) else { return "" }
            return string as Swift.String
        } catch {
            return ""
        }
    }
    
}


extension JSON {
    
    /// The JSON tree formatted as NSObject-compatible objects.
    public var NSJSONValue: NSObject {
        switch self {
        case .Number(let num):
            return num
        case .String(let str):
            return str
        case .Boolean(let bool):
            return bool
        case .Array(let array):
            return array.map({ $0.NSJSONValue }) as NSArray
        case .Object(let dictionary):
            var output: [NSObject: AnyObject] = [:]
            for (key, j) in dictionary {
                output[key] = j.NSJSONValue
            }
            return output
        case .Null:
            return NSNull()
        }
    }
    
}

