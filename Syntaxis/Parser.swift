//
//  Parser.swift
//  Syntaxis
//
//  Created by kronenthaler on 23/01/2020.
//  Copyright © 2020 kronenthaler. All rights reserved.
//

import Foundation

infix operator =>

public class Parser {
    public typealias State = (position: Int, maxPosition: Int)
    public typealias ParserTuple = (value: Any, state: State)
    public typealias Functor =  ([Tokenizer.Token], State) throws ->  ParserTuple
    public typealias Filter = (Tokenizer.Token) -> Bool
    public typealias Transformation = (Any) -> Any
    
    public enum ParseException: Error {
        case runtimeException(_ reason: String)
        case parsingException(reason: String, state: State)
        case unexpectedTokenException(token: String, state: State)
    }
    
    public private(set) var name: String
    var definition: Functor?
    
    init() {
        // this should be overridden in some point by the other implementations
        name = "Parser"
    }
    
    convenience init(functor: @escaping Functor) {
        self.init()
        self.definition = functor
    }
    
    private func run(_ sequence: [Tokenizer.Token], state: State) throws -> ParserTuple  {
        guard let functor: Functor = self.definition else {
            throw ParseException.runtimeException("Undefined parser function")
        }
        
        return try functor(sequence, state)
    }
    
    // IDEA: this function could leverage generics and use that as return type.
    public func parse<T: Any>(_ sequence: String, tokenizer: Tokenizer = Tokenizer.defaultTokenizer) throws -> T? {
        let tokens = tokenizer.tokenize(sequence: sequence)
        let result = try self.run(tokens, state: (0, 0))
        return result.value as? T
    }
    
    public func named(_ name: String) -> Parser {
        self.name = name
        return self
    }
}


// MARK: Operators
extension Parser {
    static func && (left: Parser, right: Parser) -> Parser {
        let _and: Functor = { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            let tupleA = try left.run(tokens, state: state)
            let tupleB = try right.run(tokens, state: tupleA.state)
            
            return (mergeValues(tupleA.value, tupleB.value), state: tupleB.state)
        }
        
        return Parser(functor: _and).named("(\(left.name) && \(right.name))")
    }
    
    private static func mergeValues(_ value1: Any, _ value2: Any) -> Any {
        // IDEA: check if this can be rewritten as a map/reduce, flatMap or something the like...
        let values = [value1, value2].filter { (x: Any) -> Bool in
            x as? Tokenizer.SpecialTokens == nil
        }
        
        if values.count == 0 {
            // IDEA: set the [value1, value2] as the ignored value ...
            return Tokenizer.SpecialTokens.ignored(token: nil) as Any
        }

        // single values make no sense as lists
        if values.count == 1 {
            return values[0]
        }
        
        // the first element is a list => flatten the second parameter into the first one
        if let firstList = values[0] as? [Any] {
            if let secondValue = values[1] as? [Any] {
                return firstList + secondValue
            }
            
            return firstList + [value2]
        }
        
        // the first element is an atom but the second in a list, prepend the first into second
        if let secondList = values[1] as? [Any] {
            return [value1] + secondList
        }
        
        return values
    }
    
    static func || (left: Parser, right: Parser) -> Parser {
        let _or: Functor = { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            do {
                return try left.run(tokens, state: state)
            } catch let error as ParseException {
                var lastState: State?
                
                switch (error) {
                    case .unexpectedTokenException(token: _, state: let tempState): fallthrough
                    case .parsingException(reason: _, state: let tempState):
                        lastState = tempState
                        break
                    default:
                        throw error
                }
                
                return try right.run(tokens, state: (state.position, lastState?.maxPosition ?? state.maxPosition))
            }
        }
        
        return Parser(functor: _or).named("(\(left.name) || \(right.name))")
    }
    
    static func => (parser: Parser, transformation: @escaping Transformation) -> Parser {
        let _transform = { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            let result = try parser.run(tokens, state: state)
            return (value: transformation(result.value), state: result.state)
        }
        return Parser(functor: _transform).named(parser.name)
    }
}

// this is the bread and butter
func token(_ target: String) -> Parser {
    return some { $0.value == target }.named("token(\(target))")
}

func pure(_ value: Any) -> Parser {
    let _pure: Parser.Functor = { (value, $1) }
    
    return Parser(functor: _pure).named("pure(\(String(describing: value)))")
}

func some(_ lambda: @escaping Parser.Filter) -> Parser {
    let _some: Parser.Functor = { (tokens: [Tokenizer.Token], state: Parser.State) throws -> Parser.ParserTuple in
        guard state.position < tokens.count else {
            throw Parser.ParseException.parsingException(reason: "No tokens left in the stream", state: state)
        }
        
        let token = tokens[state.position]
        if lambda(token) {
            let position = state.position + 1
            return (value: token.value,
                    state: (position: position, maxPosition: max(position, state.maxPosition)))
        }
        throw Parser.ParseException.unexpectedTokenException(token: token.value, state: state)
    }
    
    return Parser(functor: _some).named("some")
}

func skip(_ parser: Parser) -> Parser {
    return (parser => { Tokenizer.SpecialTokens.ignored(token: $0) }).named("skip(\(parser.name))")
}

