//
//  ParserSpec.swift
//  SyntaxisTests
//
//  Created by Ignacio Calderon on 30/01/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation
import Nimble
@testable import Syntaxis
import XCTest

class ParserSpec: XCTestCase {
    private func ptrToString (pointer buf: UnsafeMutableRawPointer, length: Int) -> String {
        let filteredArray = Array(UnsafeBufferPointer(start: buf.assumingMemoryBound(to: UInt8.self), count: length))
        return filteredArray
            .map { String(UnicodeScalar(UInt8($0))) }
            .joined()
            .components(separatedBy: "\n")[0]
    }

    private func readBuffer(from pipe: Pipe) -> String {
        let buffer = UnsafeMutableRawPointer.allocate(byteCount: 1024, alignment: 0)
        let count = read(pipe.fileHandleForReading.fileDescriptor, buffer, 1024)
        let output = ptrToString(pointer: buffer, length: count)
        close(pipe.fileHandleForWriting.fileDescriptor)
        close(pipe.fileHandleForReading.fileDescriptor)
        free(buffer)

        return output
    }

    func testRunShouldFailIfNoDefinition() {
        let parser = Parser()

        expect {
            try parser.parse("")
        }.to(throwError(Parser.RuntimeException(reason: "Undefined parser function")))
    }

    func testParserOptionsVerboseError() {
        let pipe = Pipe()
        dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout))

        let parser = token("hello") && token("Mike") && eof()
        let context = "hello                            Mike , "

        _ = try? parser.parse(context, options: [.verboseError], tokenizer: Tokenizer.wordTokenizer) as String?

        let output = readBuffer(from: pipe)

        expect(output) == "Error: Expected EOF but there are still tokens to process. At line: 1 character: 39"
    }

    func testParserOptionsPrintParser() {
        let pipe = Pipe()
        dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout))

        let parser = token("hello") && token("Mike") && eof()
        let context = "hello Mike"

        _ = try? parser.parse(context, options: [.printParser], tokenizer: Tokenizer.wordTokenizer) as String?

        let output = readBuffer(from: pipe)

        expect(output) == "((\"hello\" && \"Mike\") && <EOF>)"
    }
}
