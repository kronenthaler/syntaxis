//
//  Parser+Operators.swift
//  Syntaxis
//
//  Created by Ignacio Calderon on 08/02/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation

infix operator =>   // transform
infix operator <-   // define
postfix operator *  // zero or more (many)
postfix operator +  // one or more (one plus)

/// Syntactic sugar extensions to allow the use of simple strings as a shorhand of token(str)
public extension String {
    @inlinable static func && (left: String, right: String) -> Parser { token(left) && token(right) }
    @inlinable static func && (left: Parser, right: String) -> Parser { left && token(right) }
    @inlinable static func && (left: String, right: Parser) -> Parser { token(left) && right }

    @inlinable static func || (left: String, right: String) -> Parser { token(left) || token(right) }
    @inlinable static func || (left: Parser, right: String) -> Parser { left || token(right) }
    @inlinable static func || (left: String, right: Parser) -> Parser { token(left) || right }

    @inlinable static postfix func * (value: String) -> Parser { (token(value))* }
    @inlinable static postfix func + (value: String) -> Parser { (token(value))+ }
    @inlinable static func =><InputType: Any, ResultType: Any> (value: String, transformation: @escaping Parser.Transformation<InputType, ResultType>) -> Parser {
        return token(value) => transformation
    }
}

extension Parser {
    public static func && (left: Parser, right: Parser) -> Parser {
        return Parser("(\(left.debugDescription) + \(right.debugDescription))") { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            let tupleA = try left.run(tokens, state: state)
            let tupleB = try right.run(tokens, state: tupleA.state)

            return (value: mergeValues(tupleA.value, tupleB.value), state: tupleB.state)
        }
    }

    private static func mergeValues(_ value1: Any, _ value2: Any) -> Any {
        let values = [value1, value2].filter { $0 as? Tokenizer.SpecialTokens == nil }

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

    public static func || (left: Parser, right: Parser) -> Parser {
        return Parser("(\(left.debugDescription) || \(right.debugDescription))") { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            do {
                return try left.run(tokens, state: state)
            } catch let error as ParsingException {
                return try right.run(tokens, state: (state.position, error.state?.maxPosition ?? state.maxPosition))
            }
        }
    }

    public static func =><InputType: Any, ResultType: Any> (parser: Parser, transformation: @escaping Transformation<InputType, ResultType>) -> Parser {
        return Parser(parser.debugDescription) { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            let (value, newState) = try parser.run(tokens, state: state)
            guard let castedValue = value as? InputType else {
                throw Parser.RuntimeException(reason: "Unexpected type for transformation")
            }
            return (value: transformation(castedValue), state: newState)
        }
    }

    /// Assigns the src's parser definition into the target's definition
    /// @param target The receiving end of the operation
    /// @param src The source of the operation
    /// @return Returns the recently modified target definition
    /// @discussion This method is extremely useful whenever the grammar contains some level of self-reflection. This method allows to use a forward declaration
    /// for the definitions until all the components of this parser have been defined and then it can be assigned back to itself.
    public static func <- (target: Parser, src: Parser) -> Parser {
        target.definition = src.definition
        return target
    }

    public static postfix func * (parser: Parser) -> Parser {
        return Parser("(\(parser.debugDescription))*") { (tokens: [Tokenizer.Token], state: State) throws -> ParserTuple in
            var result: [Any] = []
            var currentState: State = state
            do {
                while true {
                    let (value, newState) = try parser.run(tokens, state: currentState)
                    currentState = newState
                    result.append(value)
                }
            } catch is ParsingException {
                return (result, currentState)
            }
        }
    }

    public static postfix func + (parser: Parser) -> Parser {
        return (parser && (parser)*)
            .named("(\(parser.debugDescription))+")
    }
}
