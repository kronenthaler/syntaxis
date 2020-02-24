//
//  ParserExceptionsSpec.swift
//  SyntaxisTests
//
//  Created by Ignacio Calderon on 24/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation
import Nimble
import XCTest
@testable import Syntaxis

class ParserExceptionsSpec: XCTestCase {

    func testParsingExceptionCoderInitializer() {
        expect {
            _ = Parser.ParsingException(coder: NSCoder())
        }.to(throwAssertion())
    }

    func testRuntimeExceptionCodecInitializer() {
        expect {
            _ = Parser.RuntimeException(coder: NSCoder())
        }.to(throwAssertion())
    }

    func testUnexpectedTokenExceptionCodecInitializer() {
        expect {
            _ = Parser.UnexpectedTokenException(coder: NSCoder())
        }.to(throwAssertion())
    }

    func testExpectionErrorMessageInMultilines() {
        let parser = token("hello") && token("Mike") && token(":")
        let context = "hello    \n      \n     \n     \n     Mike , < 20 chars after."
        do {
            _ = try parser.parse(context, tokenizer: Tokenizer.wordTokenizer) as String?
        } catch let error as Parser.ParsingException {
            let tokens = Tokenizer.wordTokenizer.tokenize(sequence: context)
            let message = error.errorMessage(context: context, tokens: tokens)
            expect(message) == """
Error: Unexpected token (,) found. At line: 5 character: 11
     Mike , < 20 chars after.
          ⤴
"""
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
            expect(message) == """
Error: Unexpected token (,) found. At line: 1 character: 39
               Mike , < 20 chars after.
                    ⤴
"""
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
            expect(message) == """
Error: Unexpected token (,) found. At line: 1 character: 39
               Mike ,
                    ⤴
"""
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
            expect(message) == """
Error: Unexpected EOF. At line: 1 character: 38
                 Mike
                    ⤴
"""
        } catch {
            fail()
        }
    }

    func testExceptionErrorMessageExpectedEOF() {
        let parser = token("hello") && token("Mike") && eof()
        let context = "hello                            Mike ,"
        do {
            _ = try parser.parse(context, tokenizer: Tokenizer.wordTokenizer) as String?
        } catch let error as Parser.ParsingException {
            let tokens = Tokenizer.wordTokenizer.tokenize(sequence: context)
            let message = error.errorMessage(context: context, tokens: tokens)
            expect(message) == """
Error: Expected EOF but there are still tokens to process. At line: 1 character: 39
               Mike ,
                    ⤴
"""
        } catch {
            fail()
        }
    }
}
