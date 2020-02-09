//
//  Parser+Exception.swift
//  Syntaxis
//
//  Created by Ignacio Calderon on 08/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation

extension Parser {
    public class Exception: NSException, Error {
        public class RuntimeException : Exception {
            init(reason: String){
                super.init(name: NSExceptionName(rawValue: "Runtime parsing Exception"), reason: reason, userInfo: nil)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        public class ParsingException: Exception {
            public func errorMessage(context: String, tokens: [Tokenizer.Token]) -> String {
                guard let state = self.state else { return "" }
                
                // find infracting token based on the state
                let token: Tokenizer.Token = tokens[state.position]
                
                // count how many newlines there are between 0-token.range.location
                let prefixIndex = context.index(context.startIndex, offsetBy: token.range.lowerBound + 1)
                let prefix = context[..<prefixIndex]
                let lines = prefix.components(separatedBy: CharacterSet(charactersIn: "\n\r"))
                
                // the amount of characters in the last line is the position of the first bad token.
                let lastLine = lines.last!
                
                // lowerbound should the either (0: beginning of str, -20: if no \n, -x: x the index of the first \n going backwards from the lowerbound)
                // delta:                           lowerbound,            +20,          +x
                // shift(delta) + ^
                // max(0, token.range.location - 20)
                var shift = token.range.lowerBound
                var offset = 0
                if token.range.location - 20 > 0 {
                    offset = token.range.location - 20
                    shift = 20
                }
                
                // TODO: check if it's possible to search backwards in one instruction
                for i in stride(from: token.range.lowerBound, to: offset, by: -1){
                    let charAt = context[context.index(context.startIndex, offsetBy:i)]
                    if(charAt == Character("\n")){
                        offset = i + 1
                        shift = token.range.lowerBound - i - 1
                        break
                    }
                }
                
                let lowerBoundIndex = context.index(context.startIndex, offsetBy: offset)
                let upperBoundIndex = context.index(context.startIndex, offsetBy: token.range.upperBound + min(20, context.count - token.range.upperBound))
                let target = context[lowerBoundIndex..<upperBoundIndex]
                
                // construct the message to output
                return "\(target)\n\(String(repeating:"~", count: shift) + "^")\nError: \(self.reason!) At line: \(lines.count) character: \(lastLine.count)"
            }
            
            public private(set) var state: State?
            
            init(reason: String, state: State? = nil){
                self.state = state
                super.init(name: NSExceptionName(rawValue: "Parsing exception"), reason: reason, userInfo: [:])
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            public static func == (lhs: ParsingException, rhs: ParsingException) -> Bool {
                return lhs.reason == rhs.reason &&
                    lhs.state?.position == rhs.state?.position &&
                    lhs.state?.maxPosition == rhs.state?.maxPosition
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
            
            public static func == (lhs: UnexpectedTokenException, rhs: UnexpectedTokenException) -> Bool {
                return lhs.reason == rhs.reason &&
                    lhs.token == rhs.token &&
                    lhs.state?.position == rhs.state?.position &&
                    lhs.state?.maxPosition == rhs.state?.maxPosition
            }
        }
    }
}
