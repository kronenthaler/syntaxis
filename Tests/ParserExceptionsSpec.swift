//
//  ParserExceptionsSpec.swift
//  SyntaxisTests
//
//  Created by Ignacio Calderon on 24/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation
import Nimble
@testable import Syntaxis
import XCTest

class ParserExceptionsSpec: XCTestCase {
    private let parser = "hello" && "Mike" && ":" && EOF

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
        let context = "hello    \n      \n     \n     \n     Mike , < 20 chars after."
        var expectedMessage = ""
        expectedMessage += "Error: Unexpected token (,) found. At line: 5 character: 11\n"
        expectedMessage += "     Mike , < 20 chars after.\n"
        expectedMessage += "          ^"

        validateException(context, expectedMessage: expectedMessage)
    }

    func testExpectionErrorMessageInSingleLine() {
        let context = "hello                            Mike , < 20 chars after."
        var expectedMessage = ""
        expectedMessage += "Error: Unexpected token (,) found. At line: 1 character: 39\n"
        expectedMessage += "               Mike , < 20 chars after.\n"
        expectedMessage += "                    ^"

        validateException(context, expectedMessage: expectedMessage)
    }

    func testExceptionErrorMessageAtBeginningOfLine() {
        let context = "Hello                            Mike , < 20 chars after."
        var expectedMessage = ""
        expectedMessage += "Error: Unexpected token (Hello) found. At line: 1 character: 1\n"
        expectedMessage += "Hello                    \n"
        expectedMessage += "^^^^^"

        validateException(context, expectedMessage: expectedMessage)
    }

    func testExceptionErrorMessageAtEndOfLine() {
        let context = "hello                            Mike ,\n < 20 chars after."
        var expectedMessage = ""
        expectedMessage += "Error: Unexpected token (,) found. At line: 1 character: 39\n"
        expectedMessage += "               Mike ,\n"
        expectedMessage += "                    ^"

        validateException(context, expectedMessage: expectedMessage)
    }

    func testExceptionErrorMessageAtEndOfFile() {
        let context = "hello                            Mike"
        var expectedMessage = ""
        expectedMessage += "Error: Unexpected EOF. At line: 1 character: 38\n"
        expectedMessage += "                 Mike\n"
        expectedMessage += "                    ^"

        validateException(context, expectedMessage: expectedMessage)
    }

    func testExceptionErrorMessageExpectedEOF() {
        let context = "hello                            Mike : xx"
        var expectedMessage = ""
        expectedMessage += "Error: Expected EOF but there are still tokens to process. At line: 1 character: 41\n"
        expectedMessage += "             Mike : xx\n"
        expectedMessage += "                    ^^"

        validateException(context, expectedMessage: expectedMessage)
    }

    private func validateException(_ context: String, expectedMessage: String) {
        do {
            _ = try parser.parse(context, tokenizer: Tokenizer.wordTokenizer) as String?
        } catch let error as Parser.ParsingException {
            let tokens = Tokenizer.wordTokenizer.tokenize(sequence: context)
            let message = error.errorMessage(context: context, tokens: tokens)

            expect(message) == expectedMessage
        } catch {
            fail()
        }
    }
}
