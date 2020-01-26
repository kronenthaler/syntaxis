//
//  Tokenizer.swift
//  Syntaxis
//
//  Created by kronenthaler on 23/01/2020.
//  Copyright © 2020 kronenthaler. All rights reserved.
//

import Foundation

public protocol TokenType {}
typealias ParserToken = (value: String, type: TokenType)

// TODO: there is probably a nicer way to define the token definition with a single enum + associated values (e.g. the index)
typealias TokenDefinition = (index: Int, type: TokenType)

class Tokenizer {
    var regex: NSRegularExpression
    var rules: [TokenDefinition]
    
    init(expression: String, rules: [TokenDefinition]) throws {
        self.regex = try NSRegularExpression(pattern: expression, options:.caseInsensitive)
        self.rules = rules
    }
    
    func tokenize(sequence: String) -> [ParserToken] {
        let fasterSequence = sequence as NSString
        
        let matches = self.regex .matches(in: sequence, options: [], range: NSMakeRange(0, sequence.count))
        var tokens: [ParserToken] = []
        
        let size = self.rules.count
        for match in matches {
            for i in 0..<size {
                let definition = self.rules[i].index
                guard definition < match.numberOfRanges else {
                    continue
                }
                
                let range: NSRange = match.range(at: definition)
                tokens.append((value: fasterSequence.substring(with: range), type: self.rules[i].type))
            }
        }
        
        return tokens
    }
}
