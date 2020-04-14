# Fundamentals

## Basics

Functional parsing is based in some atomic operations known as combinators that act as small building blocks to be composed and create more complex behaviors.

In its very essence, a _parser_ is a function `p` that receives a sequence of tokens and a state, and returns a tuple, with a parsed value and a new state. Formally: `p([tokens], state) -> (value, state)`

The sequence of tokens, could be simply characters, whole strings, or other objects containing additional metadata (such as token position, length and type)

A _parser combinator_ (or _combinator_ for short), is a function that receives some special input, and outputs a _parser_, i.e. a function that has been constructed using the input parameters.

## Parser Combinators 

_Syntaxis_ provides with a set of parser combinators that can be join together to achieve more complex parsers. Essentially, whenever you write your parser, you are actually creating a new (very specific) parser combinator. Most of these parser's usages are demonstrated in the example [here](https://github.com/kronenthaler/syntaxis/tree/master/Docs/first-parser.md).

| Combinator/Operator                    | Description                                                  |
| -------------------------------------- | ------------------------------------------------------------ |
| `pure(value: Any) -> Parser`           | Returns a parser that contains the given _value, a.k.a. Identity parser. |
| `some(filter: Filter) -> Parser`       | Returns a parser that applies the filter function over the next token, and if the filter function returns true, it returns the matched value, if not throws an exception `Parser.UnexpectedTokenException` |
| `tokenType(type: TokenType) -> Parser` | Returns a parser that checks if the next token in the queue is of the same specified type and it returns it. |
| `token(needle: String) -> Parser`      | Returns a parser that matches the given string against the next token in the queue. |
| `skip(parser: Parser) -> Parser`       | Returns a parser that evaluates the given parser, and in case of success, discards its result. This is extremely useful to ensure correct syntax but discard elements that are delimiters of the syntax. |
| `maybe(parser: Parser) -> Parser`      | Returns a parser that provides optionality of elements in the syntax. If the given _parser_ fails, it resets the position and continues from the point before the evaluation. This parser never fails. |
| `let EOF: Parser`                      | It's a static parser that validates that there are no more tokens in the stream. Useful to ensure the stream parsed is completely processed. |
| `(Parser && Parser) -> Parser`         | AND operator. Returns a parser that ensures that both given parsers are successful. Stops evaluating on the first **failure**. |
| `(Parser \|\| Parser) -> Parser`       | OR operator. Returns a parser that ensures that either of the given parsers are successful. Stops evaluating on the first **success**. |
| `(Parser)* -> Parser`                  | MANY operator. Returns a parser that ensures the given parser is successful zero or more times. This parser never fails. |
| `(Parser)+ -> Parser`                  | 1 or more operator. Returns a parser that ensures the given parser is successful at least once, and possible many more times afterwards. |
| `(Parser => Transformation) -> Parser` | Transformation operator. Returns a parser that will evaluate the given parser and apply the transformation function over the result to be returned. Useful to create AST's as the content gets parsed. |
| `(Parser <- Parser) -> Parser`         | Define operator. Returns a parser that has be overridden with the second parser function.  This is extremely handy for parsers with recursive nature on which one definition depends on itself (directly or indirectly). (see [example](https://github.com/kronenthaler/syntaxis/tree/master/Docs/first-parser.md#parser-definition)) |

## Syntactic sugar

Some of this combinator offer a syntactic sugar version of them to allow passing simple strings into it. They will be translated to `token(string)` parsers instead. This makes the parsers more readable and reduces the clutter without losing any expressivity.

Examples of combinators using the syntactic sugar

`skip("hello")` -> `skip(token("hello"))`

`maybe("hello")` -> `maybe(token("hello"))`

`"hello" && "John"` -> `token("hello") && token("John")` also valid for string/parser and parser/string

`"hello" || "hi"` -> `token("hello") || token("hi")` also valid for string/parser and parser/string

`("hello")*` -> `(token("hello"))*` also valid for the `()+` operator

`"hello" => { String($0.reversed())}` -> `token("hello") -> { String($0.reversed())}`

## Optimizations

Parser combinators are top-down or recursive-descent parsers, meaning that the way the grammar is defined has an impact on the performance of the parser created.

For example, if your grammar has a left-recursion, something like `<s> ::= <s> + 0 | empty` your parser _will_ get into troubles, since it will never be able to escape the left-recursion.

Also, because the parser combinators don't do look-aheads, the order on which you define your rules have a big impact on performance and how far/often the parser needs to backtrack to an stable position to keep moving forward.

For example, the JSON example [here](https://github.com/kronenthaler/syntaxis/tree/master/Docs/first-parser.md),

```swift
value <- (`null` || `true` || `false` || string || number || array || dict)
```

Performs optimally, as it discards simpler parsers progressively, leaving the most complex ones last. However, if the parser was defined like:

```swift
value <- (dict || array || number || string || `null` || `true` || `false`)
```

It will be the worse case scenario, as it will always will attempt many options failing, and in case of partial successes, it will need to unroll (backtrack) to a stable position before continuing. Meaning that the input stream will need to be traversed (partially) multiple times 