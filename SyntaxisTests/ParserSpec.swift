//
//  ParserSpec.swift
//  SyntaxisTests
//
//  Created by Ignacio Calderon on 30/01/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation
import Nimble
import XCTest
@testable import Syntaxis

class ParserSpec: XCTestCase {
    enum types: Int, TokenType {
        case word = 1
    }
    var wordTokenizer: Tokenizer {
        get {
            try! Tokenizer(expression: "(\\S+)", rules: [(index: 1, type: types.word)])
        }
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRunShouldFailIfNoDefinition() {
        let parser = Parser()
        
        expect {
            try parser.parse("")
        }.to(throwError(Parser.ParseException.runtimeException("Undefined parser function")))
    }
    
    func testTokenNotFound() {
        let parser = token("hello")
        
        expect {
            try parser.parse("hi John", tokenizer: self.wordTokenizer)
        }.to(throwUnexpectedTokenError("hi"))
    }
    
    func testTokenFound() throws {
        let parser = token("hello")
        let result: String? = try parser.parse("hello John", tokenizer: self.wordTokenizer)
        expect(result) == "hello"
    }
    
    func testNoTokensLeft() {
        let parser = token("hello")
        
        expect{
            try parser.parse("") as String?
        }.to(throwParsingError("No tokens left in the stream", state: (0, 0)))
    }
    
    func testSkipParser() {
        let parser = skip(token("hello"))
        
        let result: Tokenizer.SpecialTokens? = try? parser.parse("hello John", tokenizer: self.wordTokenizer)
        
        expect(result).to(matchIgnoredToken("hello"))
    }
    
    func testAndFailingFirstParser() {
        let parserA = token("hello")
        let parserB = token("John")
        
        let parser = parserA && parserB
        
        expect {
            try parser.parse("hi John", tokenizer: self.wordTokenizer) as String?
        }.to(throwUnexpectedTokenError("hi"))
    }
    
    func testAndFailingSecondParser() {
        let parserA = token("hello")
        let parserB = token("John")
        
        let parser = parserA && parserB
        
        expect {
            try parser.parse("hello Mike", tokenizer: self.wordTokenizer) as String?
        }.to(throwUnexpectedTokenError("Mike"))
    }
    
    func testAndSuccessIgnoredIgnored() {
        let parserA = skip(token("hello"))
        let parserB = skip(token("John"))
        
        let parser = parserA && parserB
        
        let result = try! parser.parse("hello John", tokenizer: self.wordTokenizer) as Tokenizer.SpecialTokens?
        
        expect(result).to(matchIgnoredToken(nil as String?))
    }
    
    func testAndSuccessIgnoredObject() {
        let parserA = skip(token("hello"))
        let parserB = token("John")
        
        let parser = parserA && parserB
        
        let result = try! parser.parse("hello John", tokenizer: self.wordTokenizer) as String?
        
        expect(result) == "John"
    }
    
    func testAndSuccessIgnoredList() {
        let parserA = skip(token("hello"))
        let parserB = token("John") && token("Doe")
        
        let parser = parserA && parserB
        
        let result = try! parser.parse("hello John Doe", tokenizer: self.wordTokenizer) as [String]?
        
        expect(result) == ["John", "Doe"]
    }
    
    func testAndSuccessObjectIgnored() {
        let parserA = token("hello")
        let parserB = skip(token("John"))
        
        let parser = parserA && parserB
        
        let result = try! parser.parse("hello John", tokenizer: self.wordTokenizer) as String?
        
        expect(result) == "hello"
    }
    
    func testAndSuccessObjectObject() {
        let parserA = token("hello")
        let parserB = token("John")
        
        let parser = parserA && parserB
        
        let result = try! parser.parse("hello John", tokenizer: self.wordTokenizer) as [String]?
        
        expect(result) == ["hello", "John"]
    }
    
    func testAndSuccessObjectList() {
        let parserA = token("hello")
        let parserB = token("John") && token("Doe")
        
        let parser = parserA && parserB
        
        let result = try! parser.parse("hello John Doe", tokenizer: self.wordTokenizer) as [String]?
        
        expect(result) == ["hello", "John", "Doe"]
    }
    
    func testAndSuccessListIgnored() {
        let parserA = token("hello") && token("John")
        let parserB = skip(token("Doe"))
        
        let parser = parserA && parserB
        
        let result = try! parser.parse("hello John Doe", tokenizer: self.wordTokenizer) as [String]?
        
        expect(result) == ["hello", "John"]
    }
    
    func testAndSuccessListObject() {
        let parserA = token("hello") && token("John")
        let parserB = token("Doe")
        
        let parser = parserA && parserB
        
        let result = try! parser.parse("hello John Doe", tokenizer: self.wordTokenizer) as [String]?
        
        expect(result) == ["hello", "John", "Doe"]
    }
    
    func testAndSuccessListList() {
        let parserA = token("hello") && token("John")
        let parserB = token("long") && token("time")
        
        let parser = parserA && parserB
        
        let result = try! parser.parse("hello John long time", tokenizer: self.wordTokenizer) as [String]?
        
        expect(result) == ["hello", "John", "long", "time"]
    }
    
    func testOrFirstSuccessful() {
        let parserA = token("hello")
        let parserB = token("hi")
        
        let parser = parserA || parserB
        
        let result = try! parser.parse("hello John", tokenizer: self.wordTokenizer) as String?
        
        expect(result) == "hello"
    }
    
    func testOrSecondSuccessful() {
        let parserA = token("hello")
        let parserB = token("hi")
        
        let parser = parserA || parserB
        
        let result = try! parser.parse("hi John", tokenizer: self.wordTokenizer) as String?
        
        expect(result) == "hi"
    }
    
    func testOrBothFailed() {
        let parserA = token("hello")
        let parserB = token("hi")
        
        let parser = parserA || parserB
        
        expect {
            try parser.parse("howdy John", tokenizer: self.wordTokenizer) as String?
        }.to(throwUnexpectedTokenError("howdy", state: (0, 0)))
    }
}
