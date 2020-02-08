//
//  Parser+Operators.swift
//  Syntaxis
//
//  Created by Ignacio Calderon on 08/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation

infix operator =>   // transform
postfix operator *  // zero or more (many)
postfix operator +  // one or more (one plus)


extension Parser {
    static func && (left: Parser, right: Parser) -> Parser {
        return Parser() { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            let tupleA = try left.run(tokens, state: state)
            let tupleB = try right.run(tokens, state: tupleA.state)
            
            return (mergeValues(tupleA.value, tupleB.value), state: tupleB.state)
        }
        .named("(\(left.debugDescription) && \(right.debugDescription))")
    }
    
    private static func mergeValues(_ value1: Any, _ value2: Any) -> Any {
        // IDEA: check if this can be rewritten as a map/reduce, flatMap or something the like...
        let values = [value1, value2].filter { (x: Any) -> Bool in
            x as? Tokenizer.SpecialTokens == nil
        }
        
        if values.count == 0 {
            return Tokenizer.SpecialTokens.ignored(token: nil) as Any
        }

        // single values make no sense as lists
        if values.count == 1 {
            return values[0]
        }
        
        // the first element is a list => flatten the second parameter into the first one
        if let firstList = value1 as? [Any] {
            if let secondValue = value2 as? [Any] {
                return firstList + secondValue
            }
            
            return firstList + [value2]
        }
        
        // the first element is an atom but the second in a list, prepend the first into second
        if let secondList = value2 as? [Any] {
            return [value1] + secondList
        }
        
        return values
    }
    
    static func || (left: Parser, right: Parser) -> Parser {
        return Parser() { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            do {
                return try left.run(tokens, state: state)
            } catch let error as Exception.ParsingException {
                return try right.run(tokens, state: (state.position, error.state?.maxPosition ?? state.maxPosition))
            }
        }
        .named("(\(left.debugDescription) || \(right.debugDescription))")
    }
    
    static func => (parser: Parser, transformation: @escaping Transformation) -> Parser {
        return Parser() { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            let (value, newState) = try parser.run(tokens, state: state)
            return (value: transformation(value), state: newState)
        }
        .named(parser.debugDescription)
    }
    
    static postfix func * (parser: Parser) -> Parser {
        return Parser() { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            var result: [Any] = []
            do {
                var currentState: State = state
                while true {
                    let (value, newState) = try parser.run(tokens, state: currentState)
                    currentState = newState
                    result.append(value)
                }
            } catch let error as Exception.ParsingException {
                return (result, error.state ?? state)
            }
        }
        .named("(\(parser.debugDescription))*")
    }
    
    static postfix func + (parser: Parser) -> Parser {
        return (parser && (parser)*)
            .named("(\(parser.debugDescription))+")
    }
}