//
//  Parser.swift
//  Syntaxis
//
//  Created by kronenthaler on 23/01/2020.
//  Copyright © 2020 kronenthaler. All rights reserved.
//

import Foundation


public class BaseParser {
    public typealias State = (position: Int64, maxPosition: Int64)
    public typealias ParserTuple = (value: AnyObject, state: State)
    public typealias Functor =  ([Tokenizer.Token], State) throws ->  ParserTuple
    public typealias Filter = (Tokenizer.Token) -> Bool
    public typealias Transformation = (AnyObject) -> AnyObject
    
    public enum ParseException: Error {
        case runtimeException(_ reason: String)
        case parsingException(reason: String, state: State)
        case unexpectedTokenException(token: String, state: State)
    }
    
    public static let defaultTokenizer: Tokenizer = Tokenizer()
    public var name: String
    var definition: Functor?
    
    init(functor: @escaping Functor) {
        self.definition = functor
        name = "Parser" // this should be overridden in some point by the other implementations
    }
    
    private func run(_ sequence: [Tokenizer.Token], state: State) throws -> ParserTuple  {
        guard let functor: Functor = self.definition else {
            throw ParseException.runtimeException("Undefined parser function")
        }
        
        return try functor(sequence, state)
    }
    
    // IDEA: this function could leverage generics and use that as return type.
    public func parse(_ sequence: String, tokenizer: Tokenizer = BaseParser.defaultTokenizer) throws -> AnyObject {
        let tokens = tokenizer.tokenize(sequence: sequence)
        return try self.run(tokens, state: (0, 0)).value
    }
    
    public func named(_ name: String) -> BaseParser {
        self.name = name
        return self
    }
    
    static func && (left: BaseParser, right: BaseParser) throws -> BaseParser {
        let _and: Functor = { (tokens: [Tokenizer.Token], state: State) -> ParserTuple in
            let tupleA = try left.run(tokens, state: state)
            let tupleB = try right.run(tokens, state: tupleA.state)
            
            return (mergeValues(tupleA.value, tupleB.value), state: tupleB.state)
        }
        
        return BaseParser(functor: _and).named("(\(left.name) && \(right.name))")
    }
}


func mergeValues(_ value1: AnyObject, _ value2: AnyObject) -> AnyObject {
    // IDEA: check if this can be rewritten as a map/reduce, flatMap or something the like...
    /**
     
     [f, s].compactMap { x as? Tokenizer.SpecialTokens ? nil : x } // filter the elements
     // probably will not work the reduce part because an initial state needs to be used for the aggregation and that value is returned in the first parameter in the
     // first call...
     .reduce(Tokenizer.SpecialTokens.ignored(token:nil)) {
        x, y in
            // how to accumulate the result
            if x is list and y is list => [x,y].flatMap($0)
            
     }
     */
    let values = [value1, value2].filter { (x: AnyObject) -> Bool in
        x as? Tokenizer.SpecialTokens != nil
    }
    
    if values.count == 0 {
        return Tokenizer.SpecialTokens.ignored(token: nil) as AnyObject
    }

    // single values make no sense as lists
    if values.count == 1 {
        return values[0]
    }
    
    // the first element is a list => flatten the second parameter into the first one
    if var firstList = values[0] as? [AnyObject] {
        if let secondValue = values[1] as? [AnyObject] {
            // take a look at the flatMap function as the behavior could be very similar to what we have here...
            firstList.append(contentsOf: secondValue)
        }else{
            firstList.append(value2)
        }
        return firstList as AnyObject
    }
    
    // the first element is an atom but the second in a list, prepend the first into second
    if var secondList = values[1] as? [AnyObject] {
        secondList.insert(value1, at: 0)
        return secondList as AnyObject
    }
    
    return values as AnyObject
}
