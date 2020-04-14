//
//  Parser+Combinators.swift
//  Syntaxis
//
//  Created by Ignacio Calderon on 08/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation

public func token(_ target: String) -> Parser {
    return some { $0.value == target }
        .named("\"\(target)\"")
}

public func pure(_ value: Any) -> Parser {
    return Parser("pure(\(String(describing: value)))") { (value, $1) }
}

public func some(_ lambda: @escaping Parser.Filter) -> Parser {
    return Parser("filter()") { (tokens: [Tokenizer.Token], state: Parser.State) throws -> Parser.ParserTuple in
        guard state.position < tokens.count else {
            throw Parser.ParsingException(reason: "Unexpected EOF.", state: state)
        }

        let token = tokens[state.position]
        if lambda(token) {
            let position = state.position + 1
            return (value: token.value,
                    state: (position: position, maxPosition: max(position, state.maxPosition)))
        }
        throw Parser.UnexpectedTokenException(token: token.value, state: state)
    }
}

@inlinable
public func tokenType<T: TokenType>(_ tokenType: T) -> Parser where T: Equatable {
    return some { ($0.type as? T) == tokenType }
}

@inlinable public func skip(_ value: String) -> Parser { skip(token(value)) }
public func skip(_ parser: Parser) -> Parser {
    return (parser => { Tokenizer.SpecialTokens.ignored(token: $0) })
        .named("skip(\(parser.debugDescription))")
}

@inlinable public func maybe(_ value: String) -> Parser { maybe(token(value)) }
public func maybe(_ parser: Parser) -> Parser {
    return (parser || pure(Tokenizer.SpecialTokens.ignored(token: nil)))
        .named("[\(parser.debugDescription)]")
}

public let EOF: Parser = Parser("<EOF>") { (tokens: [Tokenizer.Token], state: Parser.State) throws -> Parser.ParserTuple in
    if state.position == tokens.count {
        return (Tokenizer.SpecialTokens.ignored(token: "EOF"), state)
    }

    throw Parser.ParsingException(reason: "Expected EOF but there are still tokens to process.", state: state)
}
