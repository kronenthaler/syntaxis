![Build Status](https://github.com/kronenthaler/syntaxis/workflows/branch-check/badge.svg?branch=master)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/5ddf9d1cd3074694923c1ac0b35654a3)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=kronenthaler/syntaxis&amp;utm_campaign=Badge_Grade) 

# Syntaxis

A functional parsing library based on parser combinators

# Getting started

## Installation

*Note: Currently it only supports installation via Cocoapods.* 

Simply add this pod to your `Podfile`

```ruby
pod 'Syntaxis'
```

## Create your first parser

We will be creating a JSON parser as it provides most of the important features you will find in a real life parser. We will be creating a parser that complies with the following grammar (BNF style)

```
<json> ::= <array> | <dict> | <number> | <string> | <boolean> | null
<boolean> ::= true | false
<string> ::= \" <char>* \"

<number> ::= [-](0|<non-zero-digit>{<digit>})[.<digit>{<digit>}][(e|E)[(+|-)]<digit>{<digit>}]
<non-zero-digit> ::= 1 | 2 | 3 | 4 | ... | 9
<digit> ::= 0 | <non-zero-digit>

<array> ::= "[" [<json> {, <json>}] "]"

<dict> ::= "{" [<pair> {, <pair>} ]"}"
<pair> ::= \"<string>\" : <json>
```

*Legend*:

* **[ X ]** means 0 or 1 times *X*
* **{ X }** means 0 or more times *X*
* **(X|Y)** means a grouped selection of *X* or *Y*

### Tokenization

Create an enum that implements `TokenType` with all kinds of valid tokens

```swift
enum JsonTokenType: Int, TokenType {
    case `null` = 0
    case `false`
    case `true`
    case numeric
    case string
    case `operator` // for all possible meaningful tokens: [, ], {, }, : and ,
}
```

Now we need to create a regular expression that allows us to chunk the input stream into these meaningful tokens.

```swift
let regex = try NSRegularExpression(pattern: #"""
                (?x)
                (null)|
                (false)|
                (true)|
                "([^"\n]*?)"|
                (-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)|
                ([\{\}\[\]:,])
                """#, options: [])
```

Finally, we are going to create a `Tokenizer` with the regular expression and tell the tokenizer what each one of those regex groups are supposed to mean

```swift
let tokenizer = Tokenizer(expression: regex, rules: [
                    (1, JsonTokenType.null),
                    (2, JsonTokenType.false),
                    (3, JsonTokenType.true),
                    (4, JsonTokenType.string),
                    (5, JsonTokenType.numeric),
                    (6, JsonTokenType.operator)
                ])
```

The above tells the tokenizer that the first matching group `(null)`, should be labeled as a `JsonTokenType.null` and so on. 

_Important:_ beware that some expressions may contain nested matching groups. You need to consider those when passing the index into the tokenizer. [regex101.com](https://regex101.com/r/iPF3rz/2) it's a handy tool while crafting this regexes and determining the capture group indexes.

### Parser definition

TBW

### Parsing

TBW

