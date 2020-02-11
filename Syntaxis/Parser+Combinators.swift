//
//  Parser+Combinators.swift
//  Syntaxis
//
//  Created by Ignacio Calderon on 08/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation

func token(_ target: String) -> Parser {
    return some { $0.value == target }
        .named("\"\(target)\"")
}

func pure(_ value: Any) -> Parser {
    return Parser("pure(\(String(describing: value)))") { (value, $1) }
}

func some(_ lambda: @escaping Parser.Filter) -> Parser {
    return Parser("filter()") { (tokens: [Tokenizer.Token], state: Parser.State) throws -> Parser.ParserTuple in
        guard state.position < tokens.count else {
            throw Parser.Exception.ParsingException(reason: "Unexpected EOF.", state: state)
        }
        
        let token = tokens[state.position]
        if lambda(token) {
            let position = state.position + 1
            return (value: token.value,
                    state: (position: position, maxPosition: max(position, state.maxPosition)))
        }
        throw Parser.Exception.UnexpectedTokenException(token: token.value, state: state)
    }
}

func skip(_ parser: Parser) -> Parser {
    return (parser => { Tokenizer.SpecialTokens.ignored(token: $0) })
        .named("skip(\(parser.debugDescription))")
}

func maybe(_ parser: Parser) -> Parser {
    return (parser || pure(Tokenizer.SpecialTokens.ignored(token: nil)))
        .named("[\(parser.debugDescription)]")
}

func eof() -> Parser {
    return Parser("<EOF>") { (tokens: [Tokenizer.Token], state: Parser.State) throws -> Parser.ParserTuple in
        if state.position == tokens.count {
            return (Tokenizer.SpecialTokens.ignored(token: "EOF"), state)
        }
        
        throw Parser.Exception.ParsingException(reason: "Expected EOF but there are still tokens to process.", state: state)
    }
}
