import options
import stream

type
    TokenKind* = enum
        Ident
        StrLit
        Operator
        Whitespace
        KeyWord
        EOF

    Token* = tuple
        kind : TokenKind
        body : string

    Tokens* = Inputs[Token]

# token functions

proc next*(inputs: Tokens, body: string): Option[Token] =
    let input = inputs.peek()

    if input.body == body :
        inputs.skip()

        return some(input)

    return none(Token)

proc next*(inputs: Tokens, kind: TokenKind): Option[Token] =
    let input = inputs.peek()

    if input.kind == kind :
        inputs.skip()

        return some(input)

    return none(Token)

proc body*(node: Option[Token]): Option[string] =
    if node.isSome :
        return some(node.get.body)
    else :
        return none(string)