//
//  NimbleMatchers.swift
//  SyntaxisTests
//
//  Created by Ignacio Calderon on 31/01/2020.
//  Copyright © 2020 Ignacio Calderon. All rights reserved.
//

import Foundation
import Nimble
@testable import Syntaxis

func matchIgnoredToken<T: Equatable>(_ expected: T?) -> Predicate<Any> {
    return Predicate.define("equal <ignored(token:\(String(describing: expected)))>", matcher: { expression, message -> PredicateResult in
        let actual = try expression.evaluate() as? Tokenizer.SpecialTokens

        if  case let .ignored(token: tokenValue) = actual,
            let token = tokenValue as? T? {
            return PredicateResult.init(bool: token == expected, message: message)
        }

        return PredicateResult.init(status: .doesNotMatch, message: message)
    })
}
