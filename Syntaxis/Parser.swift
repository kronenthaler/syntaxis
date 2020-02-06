//
//  Parser.swift
//  Syntaxis
//
//  Created by kronenthaler on 23/01/2020.
//  Copyright © 2020 kronenthaler. All rights reserved.
//

import Foundation

infix operator =>   // transform
postfix operator *  // zero or more (many)
postfix operator +  // one or more (one plus)


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
    
    private var name: String
    var definition: Functor?
    
    init() {
        // this should be overridden in some point by the other implementations
        name = "Parser"
    }
    
    convenience init(_ functor: @escaping Functor) {
        self.init()
        self.definition = functor
    }
        
    private func run(_ sequence: [Tokenizer.Token], state: State) throws -> ParserTuple  {
        guard let functor: Functor = self.definition else {
            throw ParseException.runtimeException("Undefined parser function")
        }
        
        return try functor(sequence, state)
    }
    
    // IDEA: the capture of the exception should resolve the line and position of the error OR allow the exception type
    // to print a pretty error message if possible (2 cases of the enum)
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

extension Parser: CustomDebugStringConvertible {
    public var debugDescription: String {
        return name
    }
}


// MARK: Operators
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
            // IDEA: set the [value1, value2] as the ignored value ...
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
            } catch let error as ParseException {
                // TODO: refactor this to remove the weird switch
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
            } catch ParseException.parsingException(reason: _, state: let lastState) {
                return (result, lastState)
            } catch ParseException.unexpectedTokenException(token: _, state: let lastState) {
                return (result, lastState)
            } catch {
                throw error
            }
        }
        .named("(\(parser.debugDescription))*")
    }
    
    static postfix func + (parser: Parser) -> Parser {
        return (parser && (parser)*)
            .named("(\(parser.debugDescription))+")
    }
}

// this is the bread and butter
func token(_ target: String) -> Parser {
    return some { $0.value == target }
        .named("\"\(target)\"")
}

func pure(_ value: Any) -> Parser {
    return Parser() { (value, $1) }
        .named("pure(\(String(describing: value)))")
}

func some(_ lambda: @escaping Parser.Filter) -> Parser {
    return Parser() { (tokens: [Tokenizer.Token], state: Parser.State) throws -> Parser.ParserTuple in
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
    .named("some")
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
    return Parser() { (tokens: [Tokenizer.Token], state: Parser.State) throws -> Parser.ParserTuple in
        if state.position == tokens.count {
            return (Tokenizer.SpecialTokens.ignored(token: "EOF"), state)
        }
        
        throw Parser.ParseException.parsingException(reason: "Unexpected EOF", state: state)
    }
    .named("<EOF>")
}
