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
    public typealias Functor = ([Tokenizer.Token], State) throws -> ParserTuple
    public typealias Filter = (Tokenizer.Token) -> Bool
    public typealias Transformation = (Any) -> Any

    public struct Options: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) { self.rawValue = rawValue }

        /// print a detailed message about the location of the syntactic error
        static let verboseError = Options(rawValue: 1)

        /// print the parser representation before to the execution
        static let printParser = Options(rawValue: 1 << 1)

        /// alias of printParser + verboseError
        static let verbose: Options = [.verboseError, .printParser]

        // TO-DO: more options for formatting the error unicode/plain, colors/no-colors, stdout/stderr
    }

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
            throw RuntimeException(reason: "Undefined parser function")
        }

        return try functor(sequence, state)
    }

    public func parse<T: Any>(_ sequence: String, options: Options = [], tokenizer: Tokenizer = Tokenizer.defaultTokenizer) throws -> T? {
        let tokens = tokenizer.tokenize(sequence: sequence)
        do {
            if options.contains(.printParser) {
                print(self.debugDescription)
            }

            let result = try self.run(tokens, state: (0, 0))
            return result.value as? T
        } catch let error as ParsingException {
            if options.contains(.verboseError) {
                print(error.errorMessage(context: sequence, tokens: tokens))
            }
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
