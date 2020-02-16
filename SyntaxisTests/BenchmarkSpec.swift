//
//  BenchmarkSpec.swift
//  SyntaxisTests
//
//  Created by Ignacio Calderon on 16/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import XCTest
import Nimble
@testable import Syntaxis

class BenchmarkSpec: XCTestCase {
    var jsonParser: Parser = Parser("sample")
    var jsonTokenizer: Tokenizer = Tokenizer(expression: NSRegularExpression(), rules: [])

    enum JsonTokenType: Int, TokenType {
        case Null = 0
        case False
        case True
        case Numeric
        case String
        case Operator
    }
    override func setUp() {
        super.setUp()

        let _op = { (op: String) -> Parser in
            return skip(token(op))
        }
        let value = Parser("value")
        let _null = token("null") => { _ in return NSNull() }
        let _false = token("false") => { _ in return false }
        let _true = token("true") => { _ in return true }
        let _number = some { (token: Tokenizer.Token) -> Bool in (token.type as! JsonTokenType).rawValue == JsonTokenType.Numeric.rawValue } => { ($0 as! NSString).floatValue }
        let _string = some { (token: Tokenizer.Token) -> Bool in (token.type as! JsonTokenType).rawValue == JsonTokenType.String.rawValue }
        let _array = (_op("[") && maybe(value && (_op(",") && value)*) && _op("]")) => { [$0] }
        let member = (_string && _op(":") && value) => {
            (something: Any) -> Any in
            if let pair = something as? [Any],
                let key = pair[0] as? String {
                return [key: pair[1]]
            }
            return something
        }
        let _dict = (_op("{") && maybe(member && (_op(",") && member)*) && _op("}")) => {
            (something: Any) -> Any in
            var result: [String: Any] = [:]
            if let items = something as? [[String: Any]] {
                for item in items {
                    result = result.merging(item) { (_, new) -> Any in new }
                }
                return result
            }
            return something
        }

        jsonParser = value.define(_null || _true || _false || _string || _number || _array || _dict) && eof()

        do {
            let regex = try NSRegularExpression(pattern: "\\s*(null)\\s*|\\s*(false)\\s*|\\s*(true)\\s*|\\s*\"([^\"\n]*)\"\\s*|\\s*((-?(?:0|[1-9]\\d*)(?:\\.\\d+)?(?:[eE][+-]?\\d+)?))\\s*|\\s*([\\{\\}\\[\\]:,])\\s*", options: .caseInsensitive)
            jsonTokenizer = Tokenizer(expression: regex, rules: [
                (1, JsonTokenType.Null),
                (2, JsonTokenType.False),
                (3, JsonTokenType.True),
                (4, JsonTokenType.String),
                (5, JsonTokenType.Numeric),
                (7, JsonTokenType.Operator)
            ])
        } catch {
            fail()
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func _testParsingArrays() {
        do {
            let result = try jsonParser.parse("[\"hi\", 0, -3.14159265, true, false, null]", options: [.verboseError], tokenizer: jsonTokenizer) as [Any]?
            expect(result?[0] as? String) == "hi"
            expect(result?[1] as? Float) == 0
            expect(result?[2] as? Float) == -3.14159265
            expect(result?[3] as? Bool) == true
            expect(result?[4] as? Bool) == false
            expect(result?[5] as? NSNull) == NSNull()
        } catch {
            fail()
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
            """, options:[.verboseError], tokenizer: jsonTokenizer) as [String: Any]?
            expect(result?["a"] as? [Float]) == [1.0, 2.0, 3.0]
            expect(result?["b"] as? NSNull) == NSNull()
            expect(result?["c"] as? Bool) == true
            expect(result?["d"] as? Bool) == false
            expect(result?["e"] as? String) == "abc"
            expect((result?["f"] as! [String: Any])["a1"] as? [Int]) == []
            expect((result?["f"] as! [String: Any])["b1"] as? Float).to(equal(-0.3))
        } catch {
            fail(error.localizedDescription)
        }
    }
}
