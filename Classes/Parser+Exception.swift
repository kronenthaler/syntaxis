//
//  Parser+Exception.swift
//  Syntaxis
//
//  Created by Ignacio Calderon on 08/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation

extension Parser {
    public class RuntimeException: NSException, Error {
        init(reason: String) {
            super.init(name: NSExceptionName(rawValue: "Runtime parsing Exception"), reason: reason, userInfo: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    public class ParsingException: NSException, Error {
        public private(set) var state: State?

        init(reason: String, state: State? = nil) {
            self.state = state
            super.init(name: NSExceptionName(rawValue: "Parsing exception"), reason: reason, userInfo: [:])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public func errorMessage(context: String, tokens: [Tokenizer.Token]) -> String {
            guard let state = self.state else { return "" }
            let source = context as NSString

            var lowerBound = context.count - 1
            var upperBound = context.count
            if state.position < tokens.count {
                let token: Tokenizer.Token = tokens[state.position]
                lowerBound = token.range.lowerBound
                upperBound = token.range.upperBound
            }

            // count how many newlines there are between [0, token.range.location)
            let prefixIndex = context.index(context.startIndex, offsetBy: lowerBound + 1)
            let prefix = context[..<prefixIndex]
            let lines = prefix.components(separatedBy: CharacterSet(charactersIn: "\n\r"))

            // the amount of characters in the last line is the position of the first bad token.
            let lastLine = lines.last!
            let characterPosition = state.position < tokens.count ? lastLine.count : context.count + 1

            // find the lower bound, max(0, lowerBound - 20, indexOf(\n))
            var shift = min(lowerBound, 20)
            var lowerOffset = max(0, lowerBound - 20)
            let bottomRange = NSRange(location: lowerOffset, length: lowerBound - lowerOffset)
            let lowerRange = source.range(of: "\n", options: [.backwards, .caseInsensitive], range: bottomRange)
            if lowerRange.location != NSNotFound {
                lowerOffset = lowerRange.lowerBound + 1
                shift = lowerBound - lowerRange.lowerBound - 1
            }

            // calculate upper bound clipping in the first new line character found.
            let topRange = NSRange(location: upperBound, length: min(20, context.count - upperBound))
            let upperRange = source.range(of: "\n", options: .caseInsensitive, range: topRange)
            var upperOffset = topRange.upperBound
            if upperRange.location != NSNotFound {
                upperOffset = upperRange.upperBound - 1
            }

            // get the substring
            let lowerBoundIndex = context.index(context.startIndex, offsetBy: lowerOffset)
            let upperBoundIndex = context.index(context.startIndex, offsetBy: upperOffset)
            let target = context[lowerBoundIndex..<upperBoundIndex]

            // construct the message to output
            return """
            Error: \(self.reason!) At line: \(lines.count) character: \(characterPosition)
            \(target)
            \(String(repeating: " ", count: max(0, shift)))⤴
            """
        }
    }

    public class UnexpectedTokenException: ParsingException {
        private var token: String

        init(token: String, state: State? = nil) {
            self.token = token
            super.init(reason: "Unexpected token (\(token)) found.", state: state)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
