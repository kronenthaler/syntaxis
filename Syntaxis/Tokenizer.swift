//
//  Tokenizer.swift
//  Syntaxis
//
//  Created by kronenthaler on 23/01/2020.
//  Copyright © 2020 kronenthaler. All rights reserved.
//

import Foundation

public protocol TokenType {}

public class Tokenizer {
    public typealias Token = (value: String, type: TokenType, range: NSRange)
    public typealias Definition = (index: Int, type: TokenType)
    
    private enum DefaultTokenType: Int, TokenType {
        case character = 1
        case word
    }
    
    public enum SpecialTokens {
        case ignored(token: Any?)
    }
    
    // basic tokenizers (per char, per word)
    public static let defaultTokenizer: Tokenizer = Tokenizer()
    public static let wordTokenizer: Tokenizer = try! Tokenizer(expression: "(\\S+)", rules: [(index: 1, type: DefaultTokenType.word)])
    
    // data
    private var regex: NSRegularExpression
    private var rules: [Definition]
    
    convenience init() {
        try! self.init(expression: "(.)", rules: [(index:1, type: DefaultTokenType.character)])
    }
    
    init(expression: String, rules: [Definition]) throws {
        self.regex = try NSRegularExpression(pattern: expression, options:.caseInsensitive)
        self.rules = rules
    }
    
    func tokenize(sequence: String) -> [Token] {
        let fasterSequence = sequence as NSString
        
        let matches = self.regex .matches(in: sequence, options: [], range: NSMakeRange(0, sequence.count))
        var tokens: [Token] = []
        
        let size = self.rules.count
        for match in matches {
            for i in 0..<size {
                let definition = self.rules[i].index
                guard definition < match.numberOfRanges else {
                    continue
                }
                
                let range: NSRange = match.range(at: definition)
                tokens.append((value: fasterSequence.substring(with: range), type: self.rules[i].type, range: range))
            }
        }
        
        return tokens
    }
}
