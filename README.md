[![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/kronenthaler/syntaxis/branch-check/master?logo=github&style=flat-square)](https://github.com/kronenthaler/sintaxis/actions?query=workflow%3Abranch-check)
[![Codacy branch coverage](https://img.shields.io/codacy/coverage/bf3a88799e974cf6b93b09794f80868d/master?logo=codacy&style=flat-square)](https://www.codacy.com/app/kronenthaler/syntaxis?utm_source=github.com&utm_medium=referral&utm_content=kronenthaler/pbxproj&utm_campaign=badger)
[![Codacy grade](https://img.shields.io/codacy/grade/bf3a88799e974cf6b93b09794f80868d?logo=codacy&style=flat-square)](https://www.codacy.com/app/kronenthaler/syntaxis?utm_source=github.com&utm_medium=referral&utm_content=kronenthaler/syntaxis&utm_campaign=badger)
![Cocoapods](https://img.shields.io/cocoapods/v/syntaxis?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjgiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIiB2aWV3Qm94PSIwIDAgMTc3IDEyMiI+PGRlZnMvPjxwYXRoIGZpbGw9Im5vbmUiIGQ9Ik0tMS0xaDE3N3YxMjJILTF6Ii8+PGc+PGcgZmlsbD0iI0ZGRiI+PHBhdGggZD0iTTExNSA3NGMtNCAyMS0yMiAzOC01MCAzOC0zMyAwLTU0LTI0LTU0LTUyQzExIDMzIDMxIDggNjUgOGMyOSAwIDQ3IDE4IDQ5IDQxSDkwYy0yLTEyLTExLTIxLTI1LTIxLTE5IDAtMzAgMTUtMzAgMzIgMCAxOCAxMiAzMiAzMCAzMiAxMyAwIDIyLTggMjUtMThoMjV6TTE0MyAxMGwtMTUgNiAxOCA0My0xOCA0MyAxNSA3IDEyLTI5IDktMjEtMjEtNDl6Ii8+PC9nPjwvZz48L3N2Zz4=)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/syntaxis?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjgiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIiB2aWV3Qm94PSIwIDAgMTc3IDEyMiI+PGRlZnMvPjxwYXRoIGZpbGw9Im5vbmUiIGQ9Ik0tMS0xaDE3N3YxMjJILTF6Ii8+PGc+PGcgZmlsbD0iI0ZGRiI+PHBhdGggZD0iTTExNSA3NGMtNCAyMS0yMiAzOC01MCAzOC0zMyAwLTU0LTI0LTU0LTUyQzExIDMzIDMxIDggNjUgOGMyOSAwIDQ3IDE4IDQ5IDQxSDkwYy0yLTEyLTExLTIxLTI1LTIxLTE5IDAtMzAgMTUtMzAgMzIgMCAxOCAxMiAzMiAzMCAzMiAxMyAwIDIyLTggMjUtMThoMjV6TTE0MyAxMGwtMTUgNiAxOCA0My0xOCA0MyAxNSA3IDEyLTI5IDktMjEtMjEtNDl6Ii8+PC9nPjwvZz48L3N2Zz4=)
[![Cocoapods](https://img.shields.io/cocoapods/l/syntaxis?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjgiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIiB2aWV3Qm94PSIwIDAgMTc3IDEyMiI+PGRlZnMvPjxwYXRoIGZpbGw9Im5vbmUiIGQ9Ik0tMS0xaDE3N3YxMjJILTF6Ii8+PGc+PGcgZmlsbD0iI0ZGRiI+PHBhdGggZD0iTTExNSA3NGMtNCAyMS0yMiAzOC01MCAzOC0zMyAwLTU0LTI0LTU0LTUyQzExIDMzIDMxIDggNjUgOGMyOSAwIDQ3IDE4IDQ5IDQxSDkwYy0yLTEyLTExLTIxLTI1LTIxLTE5IDAtMzAgMTUtMzAgMzIgMCAxOCAxMiAzMiAzMCAzMiAxMyAwIDIyLTggMjUtMThoMjV6TTE0MyAxMGwtMTUgNiAxOCA0My0xOCA0MyAxNSA3IDEyLTI5IDktMjEtMjEtNDl6Ii8+PC9nPjwvZz48L3N2Zz4=)](LICENSE)

# Syntaxis

A functional parsing library based on parser combinators

# Fundamentals

## Basics

Functional parsing is based in some atomic operations known as combinators that act as small building blocks to be composed and create more complex behaviors.

In its very essence, a _parser_ is a function `p` that receives a sequence of tokens and an state, and returns a tuple, with a parsed value and a new state. Formally: `p([tokens], state) -> (value, state)`

The sequence of tokens, could be simply characters, whole strings, or other objects containing additional metadata (such as token position, length and type)

A _parser combinator_ is a function that receives some special input, and outputs a _parser_, i.e. a function that has been constructed using the input parameters.

## Parser Combinators 

Syntaxis_ provides with a set of parser combinators that can be join together to achieve more complex parsers. Essentially, whenever you write your parser, you are actually creating a new (very specific) parser combinator. Most of these parser's usages are demonstrated in the example below.

- `pure(value)`: returns a parse that contains the given _value_. A.k.a. Identity parser.
- `some(filter-function)`: applies the filter function over the next token, and if the filter function returns true, it returns the matched value.
- `token(string)`: matches the given string against the next token in the queue.
- `skip(parser)`: ensures that the given _parser_ succeeds and then discards its parsed value. This is extremely useful to ensure correct syntax but discard elements that are delimiters of the syntax.
- `maybe(parser)`: provides optionality of elements in the syntax. If the given _parser_ fails, it resets the position and continues from the point before the evaluation.
- `eof()`: validates that there are no more tokens in the stream. Useful to ensure the stream parsed is completely processed.
- `parserA && parserB`: ensures that both parsers are successful
- `parserA || parserB`: ensures either parser is successful, behaves as a short-circuited operator.
- `(parser)*`: ensures the parser is successful zero or more times, also known as the _many_-operator.
- `(parser)+`: ensures the parser is successful one or more times.
- `parser => function`: transforms the output of the parser into something else. 
- `parserA <- parserB`: assigns the parserB's defining function into the parserA's one. This is extremely handy for parsers with recursive nature on which one definition depends on itself (directly or indirectly).

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
let jsonTokenizer = Tokenizer(expression: regex, rules: [
                    (1, JsonTokenType.null),
                    (2, JsonTokenType.false),
                    (3, JsonTokenType.true),
                    (4, JsonTokenType.string),
                    (5, JsonTokenType.numeric),
                    (6, JsonTokenType.operator)
                ])
```

The above tells the tokenizer that the first matching group `(null)`, should be labeled as a `JsonTokenType.null` and so on. 

_Important:_ beware that some expressions may contain nested matching groups. You need to consider those when passing the index into the tokenizer. [regex101.com](https://regex101.com/r/iPF3rz/2) it's a handy tool while crafting these regexes and determining the capture group indexes.

### Parser definition

The JSON parser can be written in a very similar way to the above BNF. Let's start with the obvious parts:

```swift
let `null` = token("null") => { _ in return NSNull() }
let `false` = token("false") => { _ in return false }
let `true` = token("true") => { _ in return true }
```

We are creating 3 independent parsers (``` `null` ```, ``` `true` ``` and ``` `false` ```) Each of them, simply match an exact token, using the provided `token` parser, and transform the parsed value into an atom (`NSNull`, `true` or `false` respectively) using the `=>` operator.

Now, the `string` parser, makes use of the `some` combinator:

```swift
let string = some { ($0.type as? JsonTokenType)?.rawValue == JsonTokenType.string.rawValue }
```

Where, `$0` is of type `Tokenizer.Token`. And simply checks that the token at hand is of type `string`. Which in turns mean that the Tokenizer matched with the regex that complies for `strings`.

The `number` parser is slightly more complex than that

```swift
let number = some { ($0.type as? JsonTokenType)?.rawValue == JsonTokenType.numeric.rawValue } => { ($0 as? NSString)?.floatValue as Any }
```

This parser, will filter the tokens based on its type, IFF the type of the current token is a numeric type in the `JsonTokenType` enum. If such, it will turn the token's string into a float value.

Next types, array and dictionary/object, need to deal with the right delimiters in the right positions and orders, however, they will discard those tokens as they don't offer anything semantically.

```swift
let `operator` = { (char: String) -> Parser in skip(token(char)) }
```

This is the first custom parser we are writing. It's a custom function that receives a string and returns a parser in its place, making use of 2 simpler parsers `token` and `skip`.

The parser, will validate that the given string is the next element in the sequence and then skip that value altogether.

This parser acts as a boilerplate for the next elements to be parsed.

In this point, we cannot write any other parser without involving some sort of recursion. Arrays contain `<json>` and dictionaries as well. Yet, we cannot define a `<json>` parser without arrays or dictionaries.

For these situations, we need to create a _forward declaration_. Which is nothing else that a placeholder parser, that we can use to define our intermediate steps, and define its function afterwards.

```swift
let value = Parser("value")
```

It's that simple.

Now we can define arrays according to the BNF above.

```swift
let array = `operator`("[") && maybe(value && (`operator`(",") && value)*) && `operator`("]")
```

Here we are making use of many combinators:

1. The `&&` operator to concatenate and ensure that all elements are present
2. The `maybe` combinator, to say that the array _may be_ empty
3. The `(x)*` combinator, to say that `x` may occur 0 or more times.
4. The `forward declaration`, because the array may contain arbitrary objects.
5. The custom parser `operator`, to skip the mandatory delimiters.

As you may have noticed, this parser, doesn't need its output transformed. That's because the `&&` operator flattens and concatenates the results between the parsers that links.

The next type to parse is dictionaries. This requires 2 parsers for simplicity, one to parse entries of the dictionary as key-values (members) and the other to group them and iterate them.

```swift
let member = (string && `operator`(":") && value) => { (something: Any) -> Any in
  guard
  	let pair = something as? [Any],
  	let key = pair[0] as? String
  else {
    return something
  }

  return [key: pair.count == 1 ? [] : (pair.count == 2 ? pair[1] : Array(pair[1...]))]
}
```

The `member` parser, makes sure there is a `string` a `:` and a `value`. But it must transform the result into a key: value entry. It must validate that the value received is an `[Any]` and its first element is a `String` (the key). If that is true, depending how many elements are in the list it creates a single entry dictionary:

* if `pair.count == 1` (only key is present) => [key: []]
* if `pair.count == 2` (key and single value) => [key: pair[1]]
* if `pair.count > 2` (key and array of values) => [key: Array(pair[1...])]

Then similarly to the `array` parser, the `dict` parser only needs to validate the structure and aggregate the entries.

```swift
let dict = (`operator`("{") && maybe(member && (`operator`(",") && member)*) && `operator`("}")) => { (something: Any) -> Any in
  var result: [String: Any] = [:]
  if let items = something as? [[String: Any]] {
    for item in items {
    	result = result.merging(item) { _, new -> Any in new }
    }
  	return result
  }
	return something
}
```

Finally, we need to put everything together for our JsonParser:

```swift
let jsonParser = (value <- (`null` || `true` || `false` || string || number || array || dict)) && eof()
```

Here we are making use of 3 new combinators:

1. `||` operator, to define a parser that could be any of the alternatives defined.
2. `eof()` combinator, to ensure we have read all the input
3. `<-` operator (define operator), to assign the parser created into the placeholder.

_Note: since we don't need to expose publicly all the intermediate steps of the parser, the `jsonParser` could be defined as a lazy var as follows_

```swift
let jsonParser: Parser = {
	let `null` = token("null") => { _ in return NSNull() }
  let `false` = token("false") => { _ in return false }
  let `true` = token("true") => { _ in return true }
  
  let number = some { ($0.type as? JsonTokenType)?.rawValue == JsonTokenType.numeric.rawValue }
            => { ($0 as? NSString)?.floatValue as Any }
  
  let string = some { ($0.type as? JsonTokenType)?.rawValue == JsonTokenType.string.rawValue 	 }
  
  let `operator` = { (char: String) -> Parser in skip(token(char)) }
  let value = Parser("value")
  
  let array = `operator`("[") && maybe(value && (`operator`(",") && value)*) && `operator`("]")
  
  let member = (string && `operator`(":") && value) => { (something: Any) -> Any in
		guard
			let pair = something as? [Any],
      let key = pair[0] as? String
    else {
      return something
    }

    return [key: pair.count == 1 ? [] : (pair.count == 2 ? pair[1] : Array(pair[1...]))]
	}
  
  let dict = (`operator`("{") && maybe(member && (`operator`(",") && member)*) && `operator`("}")) => { (something: Any) -> Any in
  	var result: [String: Any] = [:]
    if let items = something as? [[String: Any]] {
    	for item in items {
      	result = result.merging(item) { _, new -> Any in new }
      }
      return result
    }
    return something
  }
  return (value <- (`null` || `true` || `false` || string || number || array || dict)) 
  				&& eof()
}()
```

### Parsing

Executing the parsing is probably the easiest step of the chain. The only things you need for it are:

1. The string to be parsed
2. The tokenizer object
3. The parser itself

Lets use the pieces we have created so far:

```swift
do {
    let result = try jsonParser.parse("""{ "fib": [1,1,2,3,5,8,13], "enabled": true }""",
                                      tokenizer: jsonTokenizer) as [String: Any]?
} catch {
    fatalError("Unable to parse the content: \(error.localizedDescription)")
}
```

What goes on in this script?

1. The `jsonParser` object is told to parse a string that looks like a valid JSON string, using the `jsonTokenizer`

2. The result is expected to be a `[String: Any]?` and be left at `result`

3. If anything goes wrong, catch the exception and deal with it. In this case, end the execution with a fatal error message.

