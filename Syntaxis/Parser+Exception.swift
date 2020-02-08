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
            
            public private(set) var state: State?
            
            init(reason: String, state: State? = nil){
                self.state = state
                super.init(name: NSExceptionName(rawValue: "Parsing exception"), reason: reason, userInfo: nil)
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
