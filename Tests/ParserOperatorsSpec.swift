//
//  ParserOperatorsSpec.swift
//  SyntaxisTests
//
//  Created by Ignacio Calderon on 24/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation
import Nimble
import Syntaxis
import XCTest

class ParserOperatorsSpec: XCTestCase {
    func testAndFailingFirstParser() {
        let parserA = token("hello")
        let parserB = token("John")

        let parser = parserA && parserB

        expect {
            try parser.parse("hi John", tokenizer: Tokenizer.wordTokenizer) as String?
        }.to(throwError(Parser.UnexpectedTokenException(token: "hi")))
    }

    func testAndFailingSecondParser() {
        let parserA = token("hello")
        let parserB = token("John")

        let parser = parserA && parserB

        expect {
            try parser.parse("hello Mike", tokenizer: Tokenizer.wordTokenizer) as String?
        }.to(throwError(Parser.UnexpectedTokenException(token: "Mike")))
    }

    func testAndSuccessIgnoredObject() {
        let parserA = skip("hello")
        let parserB = token("John")

        let parser = parserA && parserB

        let result = try? parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "John"
    }

    func testAndSuccessIgnoredList() {
        let parserA = skip("hello")
        let parserB = "John" && "Doe"

        let parser = parserA && parserB

        let result = try? parser.parse("hello John Doe", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["John", "Doe"]
    }

    func testAndSuccessObjectIgnored() {
        let parserA = token("hello")
        let parserB = skip("John")

        let parser = parserA && parserB

        let result = try? parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "hello"
    }

    func testAndSuccessObjectObject() {
        let parserA = token("hello")
        let parserB = token("John")

        let parser = parserA && parserB

        let result = try? parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John"]
    }

    func testAndSuccessObjectList() {
        let parserA = token("hello")
        let parserB = "John" && "Doe"

        let parser = parserA && parserB

        let result = try? parser.parse("hello John Doe", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John", "Doe"]
    }

    func testAndSuccessListIgnored() {
        let parserA = "hello" && "John"
        let parserB = skip("Doe")

        let parser = parserA && parserB

        let result = try? parser.parse("hello John Doe", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John"]
    }

    func testAndSuccessListObject() {
        let parserA = "hello" && "John"
        let parserB = token("Doe")

        let parser = parserA && parserB

        let result = try? parser.parse("hello John Doe", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John", "Doe"]
    }

    func testAndSuccessListList() {
        let parserA = "hello" && "John"
        let parserB = "long" && "time"

        let parser = parserA && parserB

        let result = try? parser.parse("hello John long time", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John", "long", "time"]
    }

    func testOrFirstSuccessful() {
        let parserA = token("hello")
        let parserB = "hi"

        let parser = parserA || parserB

        let result = try? parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "hello"
    }

    func testOrSecondSuccessful() {
        let parserA = "hello"
        let parserB = token("hi")

        let parser = parserA || parserB

        let result = try? parser.parse("hi John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "hi"
    }

    func testOrBothFailed() {
        let parserA = "hello"
        let parserB = "hi"

        let parser = parserA || parserB

        expect {
            try parser.parse("howdy John", tokenizer: Tokenizer.wordTokenizer) as String?
        }.to(throwError(Parser.UnexpectedTokenException(token: "howdy", state: (0, 0))))
    }

    func testTransformUnexpectedInputType() {
        let parser = "hello" => { (_: [String]) -> String in return "" }

        expect {
            try parser.parse("hello", tokenizer: Tokenizer.wordTokenizer) as String?
        }.to(throwError(Parser.RuntimeException(reason: "Unexpected type for transformation")))
    }
}
