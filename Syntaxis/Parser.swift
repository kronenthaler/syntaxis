//
//  Parser.swift
//  Syntaxis
//
//  Created by kronenthaler on 23/01/2020.
//  Copyright © 2020 kronenthaler. All rights reserved.
//

import Foundation

typealias ParserState = (position: Int64, maxPosition: Int64)
typealias ParserTuple = (value: AnyObject, state: ParserState)
typealias Functor =  ([ParserToken], ParserState) -> ParserTuple
typealias Transformation = (AnyObject) -> AnyObject
typealias ParserFilter = (ParserToken) -> Bool

public class BaseParser{
    public var name: String
    var definition: Functor
    
    init(functor: @escaping Functor) {
        self.definition = functor
        name = "Parser" // this should be overridden in some point by the other implementations
    }
}
