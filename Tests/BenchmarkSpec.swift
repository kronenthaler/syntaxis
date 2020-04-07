//
//  BenchmarkSpec.swift
//  SyntaxisTests
//
//  Created by Ignacio Calderon on 16/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Nimble
@testable import Syntaxis
import XCTest

class BenchmarkSpec: XCTestCase {
    let jsonParser: Parser = {
        let value = Parser("value")
        let `null` = token("null") => { (_: String) -> NSNull in return NSNull() }
        let `false` = token("false") => { (_: String) -> Bool in return false }
        let `true` = token("true") => { (_: String) -> Bool in return true }
        let number = tokenType(JsonTokenType.numeric) => { (value: String) -> Float in Float(value)! }
        let string = tokenType(JsonTokenType.string)
        let array = skip("[") && maybe(value && (skip(",") && value)*) && skip("]")
        let member = (string && skip(":") && value) => { (pair: [Any]) -> [String: Any] in
            guard let key = pair[0] as? String else {
                return [:]
            }

            return [key: pair.count == 1 ? [] : (pair.count == 2 ? pair[1] : Array(pair[1...]))]
        }
        let dict = (skip("{") && maybe(member && (skip(",") && member)*) && skip("}")) => { (items: [[String: Any]]) -> [String: Any] in
            var result: [String: Any] = [:]
            for item in items {
                result = result.merging(item) { _, new -> Any in new }
            }
            return result
        }
        return (value <- (`null` || `true` || `false` || string || number || array || dict)) && EOF
    }()

    var jsonTokenizer: Tokenizer = Tokenizer(expression: NSRegularExpression(), rules: [])

    enum JsonTokenType: Int, TokenType {
        case `null` = 1
        case `false`
        case `true`
        case numeric
        case string
        case symbol
    }

    override func setUp() {
        super.setUp()

        do {
            let regex = try NSRegularExpression(pattern: #"""
                (?x)
                (null)|
                (false)|
                (true)|
                "([^"\n]*?)"|
                (-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)|
                ([\{\}\[\]:,])
                """#, options: [])
            jsonTokenizer = Tokenizer(expression: regex, rules: [
                (1, JsonTokenType.null),
                (2, JsonTokenType.false),
                (3, JsonTokenType.true),
                (4, JsonTokenType.string),
                (5, JsonTokenType.numeric),
                (6, JsonTokenType.symbol)
            ])
        } catch {
            fail(error.localizedDescription)
        }
    }

    func testParsingBooleans() {
        do {
            let result = try jsonParser.parse("true", options: [.verboseError], tokenizer: jsonTokenizer) as Bool?
            expect(result) == true
        } catch {
            fail(error.localizedDescription)
        }
    }

    func testParsingStrings() {
        do {
            let result = try jsonParser.parse("\"hello world\"", options: [.verboseError], tokenizer: jsonTokenizer) as String?
            expect(result) == "hello world"
        } catch {
            fail(error.localizedDescription)
        }
    }

    func testParsingNumbers() {
        do {
            let result = try jsonParser.parse("-31415926.5e-7", options: [.verboseError], tokenizer: jsonTokenizer) as Float?
            expect(result) == -3.14159265
        } catch {
            fail(error.localizedDescription)
        }
    }

    func testParsingNulls() {
        do {
            let result = try jsonParser.parse("null", options: [.verboseError], tokenizer: jsonTokenizer) as NSNull?
            expect(result) == NSNull()
        } catch {
            fail(error.localizedDescription)
        }
    }

    func testParsingArrays() {
        do {
            let result = try jsonParser.parse("[\"hi\", 0, -3.14159265, true, false, null]",
                                              options: [.verboseError],
                                              tokenizer: jsonTokenizer) as [Any]?
            expect(result?[0] as? String) == "hi"
            expect(result?[1] as? Float) == 0
            expect(result?[2] as? Float) == -3.14159265
            expect(result?[3] as? Bool) == true
            expect(result?[4] as? Bool) == false
            expect(result?[5] as? NSNull) == NSNull()
        } catch {
            fail(error.localizedDescription)
        }
    }

    func testParsingDicts() {
        do {
            let result = try jsonParser.parse("""
            {
                "a": [1, 2, 3],
                "b": null,
                "c": true,
                "d": false,
                "e": "abc",
                "f": {
                    "a1": [],
                    "b1": -0.3
                }
            }
            """, options: [.verboseError], tokenizer: jsonTokenizer) as [String: Any]?
            expect(result?["a"] as? [Float]) == [1.0, 2.0, 3.0]
            expect(result?["b"] as? NSNull) == NSNull()
            expect(result?["c"] as? Bool) == true
            expect(result?["d"] as? Bool) == false
            expect(result?["e"] as? String) == "abc"
            expect((result?["f"] as? [String: Any])?["a1"] as? [Int]) == []
            expect((result?["f"] as? [String: Any])?["b1"] as? Float).to(equal(-0.3))
        } catch {
            fail(error.localizedDescription)
        }
    }

    func testPersformanceTokenizer100kb() {
        let bundle = Bundle(for: BenchmarkSpec.self)
        if let url = bundle.url(forResource: "sample-100kb", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let content = String(data: data, encoding: .utf8) {
            self.measure {
                _ = jsonTokenizer.tokenize(sequence: content)
            }
        }
    }

    func testPerformance100kb() {
        // load a sample json file from a decent size > 5kb
        let bundle = Bundle(for: BenchmarkSpec.self)
        if let url = bundle.url(forResource: "sample-100kb", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let content = String(data: data, encoding: .utf8) {
            self.measure {
                do {
                    let result = try jsonParser.parse(content, tokenizer: jsonTokenizer) as [Any]?
                    expect(result?.count) == 100
                } catch {
                    fail(error.localizedDescription)
                }
            }
        } else {
            fail("Unable to load sample data")
        }
    }
}
