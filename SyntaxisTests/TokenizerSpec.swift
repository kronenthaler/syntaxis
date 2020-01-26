//
//  TokenizerSpec.swift
//  SyntaxisTests
//
//  Created by kronenthaler on 23/01/2020.
//  Copyright © 2020 kronenthaler. All rights reserved.
//

import Foundation
import Nimble
import XCTest
@testable import Syntaxis

class TokenizerSpec: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInit() {
        expect{
            try Tokenizer(expression: "invalid-regex[", rules: [])
        }.to(throwError())
    }
    
    func testTokenize() {
        enum types: Int, TokenType {
            case key = 1
            case value = 2
            case unknown = 3
        }
        
        do {
            let tokenizer = try Tokenizer(expression: "\\{(.*): (.*)\\}", rules: [
                (index: 1, type: types.key),
                (index: 2, type: types.value),
                (index: 3, type: types.unknown)
            ])
            let tokens = tokenizer.tokenize(sequence: "{x: 1}")
            
            expect(tokens.count) == 2
            expect(tokens[0].value) == "x"
            expect(tokens[1].value) == "1"
        } catch let e {
            fail(e.localizedDescription)
        }
    }
}
