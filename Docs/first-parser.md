# Create your first parser

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

## Tokenization

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

## Parser definition

The JSON parser can be written in a very similar way to the above BNF. Let's start with the obvious parts:

```swift
let `null` = token("null") => { (_: String) -> NSNull in return NSNull() }
let `false` = token("false") => { (_: String) -> Bool in return false }
let `true` = token("true") => { (_: String) -> Bool in return true }
```

We are creating 3 independent parsers (``` `null` ```, ``` `true` ``` and ``` `false` ```) Each of them, simply match an exact token, using the provided `token` parser, and transform the parsed value into an atom (`NSNull`, `true` or `false` respectively) using the `=>` operator.

Now, the `string` parser, makes use of the `tokenType` combinator:

```swift
let string = tokenType(JsonTokenType.string)
```

Simply checks that the token at hand is of type `.string`. Which in turns mean that the Tokenizer matched with the regex that complies for `strings`.

The `number` parser is slightly more complex than that

```swift
let number = tokenType(JsonTokenType.numeric) => { (value: String) -> Float in Float(value)! }
```

This parser, will filter the tokens based on its type, IFF the type of the current token is a `.numeric` type in the `JsonTokenType` enum. If such, it will turn the token's string into a float value.

Next types, array and dictionary/object, need to deal with the right delimiters in the right positions and orders, however, they will discard those tokens as they don't offer anything semantically, for that purpose we will be using the `skip` operator.

In this point, we cannot write any other parser without involving some sort of recursion. Arrays contain `<json>` and dictionaries as well. Yet, we cannot define a `<json>` parser without arrays or dictionaries.

For these situations, we need to create a _forward declaration_. Which is nothing else that a placeholder parser, that we can use to define our intermediate steps, and define its function afterwards.

```swift
let value = Parser("value")
```

It's that simple.

Now we can define arrays according to the BNF above.

```swift
let array = skip("[") && maybe(value && (skip(",") && value)*) && skip("]")
```

Here we are making use of many combinators:

1. The `&&` operator to concatenate and ensure that all elements are present
2. The `maybe` combinator, to say that the array _may be_ empty
3. The `(x)*` combinator, to say that `x` may occur 0 or more times.
4. The `forward declaration`, because the array may contain arbitrary objects.
5. The syntactic sugar version of the `skip` operator. To skip the mandatory delimiters.

As you may have noticed, this parser, doesn't need its output transformed. That's because the `&&` operator flattens and concatenates the results between the parsers that links, into an array object.

The next type to parse is dictionaries. This requires 2 parsers for simplicity, one to parse entries of the dictionary as key-values (members) and the other to group them and iterate them.

```swift
let member = (string && skip(":") && value) => { (pair: [Any]) -> [String: Any] in
    guard let key = pair[0] as? String else {
        return [:]
    }

    return [key: pair.count == 1 ? [] : (pair.count == 2 ? pair[1] : Array(pair[1...]))]
}
```

The `member` parser, makes sure there is a `string`, a `:` and a `value`. But it must transform the result into a key: value entry. It must validate that its first element is a `String` (the key). If that is true, depending how many elements are in the list it creates a single entry dictionary:

* if `pair.count == 1` (only key is present) => `[key: []]`
* if `pair.count == 2` (key and single value) => `[key: pair[1]]`
* if `pair.count > 2` (key and array of values) => `[key: Array(pair[1...])]`

Then similarly to the `array` parser, the `dict` parser only needs to validate the structure and aggregate the entries.

```swift
let dict = (skip("{") && maybe(member && (skip(",") && member)*) && skip("}")) => { (items: [[String: Any]]) -> [String: Any] in
    var result: [String: Any] = [:]
    for item in items {
        result = result.merging(item) { _, new -> Any in new }
    }
    return result
}
```

Finally, we need to put everything together for our JsonParser:

```swift
let jsonParser = (value <- (`null` || `true` || `false` || string || number || array || dict)) && EOF
```

Here we are making use of 3 new combinators:

1. `||` operator, to define a parser that could be any of the alternatives defined.
2. `EOF` combinator, to ensure we have read all the input
3. `<-` operator (define operator), to assign the parser created into the placeholder.

_Note: since we don't need to expose publicly all the intermediate steps of the parser, the `jsonParser` could be defined as a lazy var as follows_

```swift
let jsonParser: Parser = {
    let value = Parser("value")
    let `null` = token("null") => { (_: String) -> NSNull in return NSNull() }
    let `false` = token("false") => { (_: String) -> Bool in return false }
    let `true` = token("true") => { (_: String) -> Bool in return true }
    let number = tokenType(JsonTokenType.numeric) => { (value: String) -> Float in Float(value)! }
    let string = tokenType(JsonTokenType.string)
    let array = skip("[") && maybe(value && (skip(",") && value)*) && skip("]")
    let member = (string && skip(":") && value) => { (pair: [Any]) -> [String: Any] in
        guard let key = pair[0] as? String else {
            return [:]
        }

        return [key: pair.count == 1 ? [] : (pair.count == 2 ? pair[1] : Array(pair[1...]))]
    }
    let dict = (skip("{") && maybe(member && (skip(",") && member)*) && skip("}")) => { (items: [[String: Any]]) -> [String: Any] in
        var result: [String: Any] = [:]
        for item in items {
            result = result.merging(item) { _, new -> Any in new }
        }
        return result
    }
    return (value <- (`null` || `true` || `false` || string || number || array || dict)) && EOF
}()
```

## Parsing

Executing the parsing is probably the easiest step of the chain. The only things you need for it are:

1. The string to be parsed
2. The tokenizer object
3. The parser itself

Lets use the pieces we have created so far:

```swift
do {
  	let jsonText = """{ "fib": [1, 1, 2, 3, 5, 8, 13], "enabled": true }"""
    let result = try jsonParser.parse(jsonText,                                    tokenizer: jsonTokenizer) as [String: Any]?
} catch {
    fatalError("Unable to parse the content: \(error.localizedDescription)")
}
```

What goes on in this script?

1. The `jsonParser` object is told to parse a string that looks like a valid JSON string, using the `jsonTokenizer`

2. The result is expected to be a `[String: Any]?` and be left at `result`

3. If anything goes wrong, catch the exception and deal with it. In this case, end the execution with a fatal error message.