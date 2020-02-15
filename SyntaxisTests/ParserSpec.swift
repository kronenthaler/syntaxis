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

    func testRunShouldFailIfNoDefinition() {
        let parser = Parser()

        expect {
            try parser.parse("")
        }.to(throwError(Parser.RuntimeException(reason: "Undefined parser function")))
    }

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
        let parser = skip(token("hello"))

        let result: Tokenizer.SpecialTokens? = try? parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer)

        expect(result).to(matchIgnoredToken("hello"))
    }

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

    func testAndSuccessIgnoredIgnored() {
        let parserA = skip(token("hello"))
        let parserB = skip(token("John"))

        let parser = parserA && parserB

        let result = try! parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as Tokenizer.SpecialTokens?

        expect(result).to(matchIgnoredToken(nil as String?))
    }

    func testAndSuccessIgnoredObject() {
        let parserA = skip(token("hello"))
        let parserB = token("John")

        let parser = parserA && parserB

        let result = try! parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "John"
    }

    func testAndSuccessIgnoredList() {
        let parserA = skip(token("hello"))
        let parserB = token("John") && token("Doe")

        let parser = parserA && parserB

        let result = try! parser.parse("hello John Doe", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["John", "Doe"]
    }

    func testAndSuccessObjectIgnored() {
        let parserA = token("hello")
        let parserB = skip(token("John"))

        let parser = parserA && parserB

        let result = try! parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "hello"
    }

    func testAndSuccessObjectObject() {
        let parserA = token("hello")
        let parserB = token("John")

        let parser = parserA && parserB

        let result = try! parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John"]
    }

    func testAndSuccessObjectList() {
        let parserA = token("hello")
        let parserB = token("John") && token("Doe")

        let parser = parserA && parserB

        let result = try! parser.parse("hello John Doe", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John", "Doe"]
    }

    func testAndSuccessListIgnored() {
        let parserA = token("hello") && token("John")
        let parserB = skip(token("Doe"))

        let parser = parserA && parserB

        let result = try! parser.parse("hello John Doe", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John"]
    }

    func testAndSuccessListObject() {
        let parserA = token("hello") && token("John")
        let parserB = token("Doe")

        let parser = parserA && parserB

        let result = try! parser.parse("hello John Doe", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John", "Doe"]
    }

    func testAndSuccessListList() {
        let parserA = token("hello") && token("John")
        let parserB = token("long") && token("time")

        let parser = parserA && parserB

        let result = try! parser.parse("hello John long time", tokenizer: Tokenizer.wordTokenizer) as [String]?

        expect(result) == ["hello", "John", "long", "time"]
    }

    func testOrFirstSuccessful() {
        let parserA = token("hello")
        let parserB = token("hi")

        let parser = parserA || parserB

        let result = try! parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "hello"
    }

    func testOrSecondSuccessful() {
        let parserA = token("hello")
        let parserB = token("hi")

        let parser = parserA || parserB

        let result = try! parser.parse("hi John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "hi"
    }

    func testOrBothFailed() {
        let parserA = token("hello")
        let parserB = token("hi")

        let parser = parserA || parserB

        expect {
            try parser.parse("howdy John", tokenizer: Tokenizer.wordTokenizer) as String?
        }.to(throwError(Parser.UnexpectedTokenException(token: "howdy", state: (0, 0))))
    }

    func testManyNoMatches() {
        let parser = (token("a"))*

        let result = try! parser.parse("bbbbb") as [String]?

        expect(result) == []
    }

    func testManyFewMatches() {
        let parser = (token("a"))*

        let result = try! parser.parse("aaaab") as [String]?

        expect(result) == ["a", "a", "a", "a"]
    }

    func testManyAllMatches() {
        let parser = (token("a"))*

        let result = try! parser.parse("aaaa") as [String]?

        expect(result) == ["a", "a", "a", "a"]
    }

    func testOnePlusNoMatches() {
        let parser = (token("a"))+

        expect {
            try parser.parse("baaa") as [String]?
        }.to(throwError(Parser.UnexpectedTokenException(token: "b")))
    }

    func testOnePlusManyMatches() {
        let parser = (token("a"))+

        let result = try! parser.parse("aaaa") as [String]?

        expect(result) == ["a", "a", "a", "a"]
    }

    func testMaybeNoMatch() {
        let parser = maybe(token("Hi"))

        let result = try! parser.parse("Hello John", tokenizer: Tokenizer.wordTokenizer) as Tokenizer.SpecialTokens?

        expect(result).to(matchIgnoredToken(nil as String?))
    }

    func testMaybeMatch() {
        let parser = maybe(token("Hello"))

        let result = try! parser.parse("Hello John", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "Hello"
    }

    func testEOFBeforeEOF() {
        let parser = token("hello") && eof()

        expect {
            try parser.parse("hello John", tokenizer: Tokenizer.wordTokenizer) as String?
        }.to(throwError(Parser.ParsingException(reason: "Unexpected EOF")))
    }

    func testEOFAtEOF() {
        let parser = token("hello") && eof()

        let result = try! parser.parse("hello   ", tokenizer: Tokenizer.wordTokenizer) as String?

        expect(result) == "hello"
    }

    func testExpectionErrorMessageInMultilines() {
        let parser = token("hello") && token("Mike") && token(":")
        let context = "hello    \n      \n     \n     \n     Mike , < 20 chars after."
        do {
            _ = try parser.parse(context, tokenizer: Tokenizer.wordTokenizer) as String?
        } catch let error as Parser.ParsingException {
            let tokens = Tokenizer.wordTokenizer.tokenize(sequence: context)
            let message = error.errorMessage(context: context, tokens: tokens)
            expect(message) == "Error: Unexpected token (,) found. At line: 5 character: 11\n     Mike , < 20 chars after.\n          ⤴"
        } catch {
            fail()
        }
    }

    func testExpectionErrorMessageInSingleLine() {
        let parser = token("hello") && token("Mike") && token(":")
        let context = "hello                            Mike , < 20 chars after."
        do {
            _ = try parser.parse(context, tokenizer: Tokenizer.wordTokenizer) as String?
        } catch let error as Parser.ParsingException {
            let tokens = Tokenizer.wordTokenizer.tokenize(sequence: context)
            let message = error.errorMessage(context: context, tokens: tokens)
            expect(message) == "Error: Unexpected token (,) found. At line: 1 character: 39\n               Mike , < 20 chars after.\n                    ⤴"
        } catch {
            fail()
        }
    }

    func testExceptionErrorMessageAtBeginningOfLine() {
        let parser = token("hi") && token("Mike") && token(":")
        let context = "hello                            Mike , < 20 chars after."
        do {
            _ = try parser.parse(context, tokenizer: Tokenizer.wordTokenizer) as String?
        } catch let error as Parser.ParsingException {
            let tokens = Tokenizer.wordTokenizer.tokenize(sequence: context)
            let message = error.errorMessage(context: context, tokens: tokens)
            expect(message) == "Error: Unexpected token (hello) found. At line: 1 character: 1\nhello                    \n⤴"
        } catch {
            fail()
        }
    }

    func testExceptionErrorMessageAtEndOfLine() {
        let parser = token("hello") && token("Mike") && token(":")
        let context = "hello                            Mike ,\n < 20 chars after."
        do {
            _ = try parser.parse(context, tokenizer: Tokenizer.wordTokenizer) as String?
        } catch let error as Parser.ParsingException {
            let tokens = Tokenizer.wordTokenizer.tokenize(sequence: context)
            let message = error.errorMessage(context: context, tokens: tokens)
            expect(message) == "Error: Unexpected token (,) found. At line: 1 character: 39\n               Mike ,\n                    ⤴"
        } catch {
            fail()
        }
    }

    func testExceptionErrorMessageAtEndOfFile() {
        let parser = token("hello") && token("Mike") && token(":")
        let context = "hello                            Mike"
        do {
            _ = try parser.parse(context, tokenizer: Tokenizer.wordTokenizer) as String?
        } catch let error as Parser.ParsingException {
            let tokens = Tokenizer.wordTokenizer.tokenize(sequence: context)
            let message = error.errorMessage(context: context, tokens: tokens)
            expect(message) == "Error: Unexpected EOF. At line: 1 character: 38\n                 Mike\n                    ⤴"
        } catch {
            fail()
        }
    }

    func testExceptionErrorMessageExpectedEOF() {
        let parser = token("hello") && token("Mike") && eof()
        let context = "hello                            Mike , "
        do {
            _ = try parser.parse(context, tokenizer: Tokenizer.wordTokenizer) as String?
        } catch let error as Parser.ParsingException {
            let tokens = Tokenizer.wordTokenizer.tokenize(sequence: context)
            let message = error.errorMessage(context: context, tokens: tokens)
            expect(message) == "Error: Expected EOF but there are still tokens to process. At line: 1 character: 39\n               Mike , \n                    ⤴"
        } catch {
            fail()
        }
    }

    private func ptrToString (pointer buf: UnsafeMutableRawPointer, length: Int) -> String {
        let filteredArray = Array(UnsafeBufferPointer(start: buf.assumingMemoryBound(to: UInt8.self), count: length))
        return filteredArray
            .map { String(UnicodeScalar(UInt8($0))) }
            .joined()
            .components(separatedBy: "\n")[0]
    }

    func testParserOptionsVerboseError() {
        let pipe = Pipe()
        dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout))

        let parser = token("hello") && token("Mike") && eof()
        let context = "hello                            Mike , "

        let _ = try? parser.parse(context, options: [.verboseError], tokenizer: Tokenizer.wordTokenizer) as String?

        let buffer = UnsafeMutableRawPointer.allocate(byteCount: 1024, alignment: 0)
        let count = read(pipe.fileHandleForReading.fileDescriptor, buffer, 1024)
        let output = ptrToString(pointer: buffer, length: count)
        close(pipe.fileHandleForWriting.fileDescriptor)
        close(pipe.fileHandleForReading.fileDescriptor)
        free(buffer)

        expect(output) == "Error: Expected EOF but there are still tokens to process. At line: 1 character: 39"
    }

    func testParserOptionsPrintParser() {
        let pipe = Pipe()
        dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout))

        let parser = token("hello") && token("Mike") && eof()
        let context = "hello Mike"

        let _ = try? parser.parse(context, options: [.printParser], tokenizer: Tokenizer.wordTokenizer) as String?

        let buffer = UnsafeMutableRawPointer.allocate(byteCount: 1024, alignment: 0)
        let count = read(pipe.fileHandleForReading.fileDescriptor, buffer, 1024)
        let output = ptrToString(pointer: buffer, length: count)
        close(pipe.fileHandleForWriting.fileDescriptor)
        close(pipe.fileHandleForReading.fileDescriptor)
        free(buffer)

        expect(output) == "((\"hello\" && \"Mike\") && <EOF>)"
    }
}
