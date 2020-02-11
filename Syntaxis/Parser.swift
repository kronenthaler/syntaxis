//
//  Parser.swift
//  Syntaxis
//
//  Created by kronenthaler on 23/01/2020.
//  Copyright © 2020 kronenthaler. All rights reserved.
//

import Foundation

public class Parser {
    public typealias State = (position: Int, maxPosition: Int)
    public typealias ParserTuple = (value: Any, state: State)
    public typealias Functor =  ([Tokenizer.Token], State) throws ->  ParserTuple
    public typealias Filter = (Tokenizer.Token) -> Bool
    public typealias Transformation = (Any) -> Any

    private var name: String
    var definition: Functor?

    init(_ name: String = "parser()") {
        // this should be overridden in some point by the other implementations
        self.name = name
    }

    convenience init(_ name: String = "parser(){", _ functor: @escaping Functor) {
        self.init(name)
        self.definition = functor
    }

    internal func run(_ sequence: [Tokenizer.Token], state: State) throws -> ParserTuple {
        guard let functor: Functor = self.definition else {
            throw Exception.RuntimeException(reason: "Undefined parser function")
        }

        return try functor(sequence, state)
    }

    // IDEA: the capture of the exception should resolve the line and position of the error OR allow the exception type
    // to print a pretty error message if possible (2 cases of the enum)
    public func parse<T: Any>(_ sequence: String, tokenizer: Tokenizer = Tokenizer.defaultTokenizer) throws -> T? {
        let tokens = tokenizer.tokenize(sequence: sequence)
        do {
            let result = try self.run(tokens, state: (0, 0))
            return result.value as? T
        } catch let error as Exception.ParsingException {
            print(error.errorMessage(context: sequence, tokens: tokens))
            throw error
        }
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
