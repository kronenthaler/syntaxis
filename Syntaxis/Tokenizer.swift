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
    public static var defaultTokenizer: Tokenizer = {
        let regex = try? NSRegularExpression(pattern: "(.)", options: .caseInsensitive)
        return Tokenizer(expression: regex ?? NSRegularExpression(), rules: [(index:1, type: DefaultTokenType.character)])
    }()

    public static var wordTokenizer: Tokenizer = {
        let regex = try? NSRegularExpression(pattern: "(\\S+)", options: .caseInsensitive)
        return Tokenizer(expression: regex ?? NSRegularExpression(), rules: [(index:1, type: DefaultTokenType.character)])
    }()

    // data
    private var regex: NSRegularExpression
    private var rules: [Definition]

    init(expression: NSRegularExpression, rules: [Definition]) {
        self.regex = expression
        self.rules = rules
    }

    func tokenize(sequence: String) -> [Token] {
        let fasterSequence = sequence as NSString

        let matches = self.regex .matches(in: sequence, options: [], range: NSRange(location: 0, length: sequence.count))
        var tokens: [Token] = []

        let size = self.rules.count
        for match in matches {
            for index in 0..<size {
                let definition = self.rules[index].index
                guard definition < match.numberOfRanges else {
                    continue
                }

                let range: NSRange = match.range(at: definition)
                tokens.append((value: fasterSequence.substring(with: range), type: self.rules[index].type, range: range))
            }
        }

        return tokens
    }
}
