//
//  TokenizerSpec.swift
//  SyntaxisTests
//
//  Created by kronenthaler on 23/01/2020.
//  Copyright © 2020 kronenthaler. All rights reserved.
//

import Foundation
import Nimble
import Syntaxis
import XCTest

class TokenizerSpec: XCTestCase {
    enum Types: Int, TokenType {
        case key = 1
        case value = 2
        case unknown = 3
    }

    func testTokenize() {
        do {
            let regex = try NSRegularExpression(pattern: #"\{(.*): (.*)\}"#, options: .caseInsensitive)
            let tokenizer = Tokenizer(expression: regex, rules: [
                (index: 1, type: Types.key),
                (index: 2, type: Types.value),
                (index: 3, type: Types.unknown)
            ])
            let tokens = tokenizer.tokenize(sequence: "{x: 1}")

            expect(tokens.count) == 2
            expect(tokens[0].value) == "x"
            expect(tokens[1].value) == "1"
        } catch {
            fail(error.localizedDescription)
        }
    }
}
