//
//  Parser+CombinatorsSpec.swift
//  SyntaxisTests
//
//  Created by Ignacio Calderon on 24/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation
import Nimble
@testable import Syntaxis
import XCTest

class ParserCombinatorsSpec: XCTestCase {
    func testTokenNotFound() {
        let parser = token("hello")

        expect {
            try parser.parse("hi John", tokenizer: Tokenizer.wordTokenizer)
        }.to(throwError(Parser.UnexpectedTokenException(token: "hi", state: (0, 0))))
    }

    func testTokenFound() throws {
        let parser = token("hello")
        let result: String? = try parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer)
        expect(result) == "hello"
    }

    func testNoTokensLeft() {
        let parser = token("hello")

        expect {
            try parser.parse("") as String?
        }.to(throwError(Parser.ParsingException(reason: "Unexpected EOF.", state: (0, 0))))
    }

    func testSkipParser() {
        let parser = skip("hello")

        let result: Tokenizer.SpecialTokens? = try? parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer)

        expect(result).to(matchIgnoredToken("hello"))
    }

    func testManyNoMatches() {
        let parser = ("a")*

        let result = try? parser.parse("bbbbb") as [String]?

        expect(result) == []
    }

    func testManyFewMatches() {
        let parser = ("a")*

        let result = try? parser.parse("aaaab") as [String]?

        expect(result) == ["a", "a", "a", "a"]
    }

    func testManyAllMatches() {
        let parser = ("a")*

        let result = try? parser.parse("aaaa") as [String]?

        expect(result) == ["a", "a", "a", "a"]
    }

    func testOnePlusNoMatches() {
        let parser = ("a")+

        expect {
            try parser.parse("baaa") as [String]?
        }.to(throwError(Parser.UnexpectedTokenException(token: "b")))
    }

    func testOnePlusManyMatches() {
        let parser = ("a")+

        let result = try? parser.parse("aaaa") as [String]?

        expect(result) == ["a", "a", "a", "a"]
    }

    func testMaybeNoMatch() {
        let parser = maybe("Hi")

        let result = try? parser.parse("Hello John", tokenizer: Tokenizer.wordTokenizer) as Tokenizer.SpecialTokens?

        expect(result).to(matchIgnoredToken(nil as String?))
    }

    func testMaybeMatch() {
        let parser = maybe("Hello")

        let result = try? parser.parse("Hello John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "Hello"
    }

    func testEOFBeforeEOF() {
        let parser = "hello" && EOF

        expect {
            try parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as String?
        }.to(throwError(Parser.ParsingException(reason: "Unexpected EOF")))
    }

    func testEOFAtEOF() {
        let parser = "hello" && EOF

        let result = try? parser.parse("hello   ", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "hello"
    }
}
