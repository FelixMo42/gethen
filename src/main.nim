type
    TokenKind = enum 
        Ident,
        NumLit,
        KeyWord,
        EOF

    Token = tuple
        kind: TokenKind
        body: string

    Tokens = ref object
        tokens : seq[Token]
        index  : int

    NodeKind = enum
        Terminal
        NonTerminal
        Failure

    Node = object
        case kind: NodeKind
        of Terminal:
            node : Token
        of NonTerminal:
            nodes : seq[Node]
        of Failure:
            discard

    Rule = proc (tokens: Tokens) : Node

    TokenOutOfBounds = object of ValueError

# token functions

proc peek*(tokens: Tokens): Token =
    if tokens.index < tokens.tokens.len :
        return tokens.tokens[tokens.index]

    if tokens.index == tokens.tokens.len :
        return (EOF, "EOF")
    
    raise newException(TokenOutOfBounds, "failed to recognize the end of file")

proc next*(tokens: Tokens) =
    tokens.index += 1

proc read*(tokens: Tokens): Token =
    # get the current token
    let token = tokens.peek()

    # increment are location in the list
    tokens.next()

    # return the current token
    return token

proc save*(tokens: Tokens): int =
    return tokens.index

proc load*(tokens: Tokens, index: int) =
    tokens.index = index

# utility

proc Toks(tokens: seq[Token]): Tokens =
    return Tokens(tokens: tokens, index: 0)

proc newNode(tokens: seq[Node]): Node =
    return Node(
        kind : NonTerminal,
        nodes : tokens
    )

proc fail(): Node =
    return Node(kind: Failure)

#

proc next(tokens: Tokens, body: string): Node =
    let token = tokens.peek()

    if token.body == body :
        tokens.next()

        return Node(kind : Terminal, node : token)
    return fail()

proc next(tokens: Tokens, kind: TokenKind): Node =
    let token = tokens.peek()

    if token.kind == kind :
        tokens.next()

        return Node(kind : Terminal, node : token)
    return fail()

proc next(tokens: Tokens, rule: Rule): Node =
    let node = rule(tokens)

    if node.kind != Failure :
        tokens.next()

        return node
    return fail()

# parse function


template expect*(tokens: Tokens, rule, node: untyped): bool =
    # set the node to be the next node
    let node = tokens.next(rule)

    # return true if is not a failure
    node.kind != Failure

template expect*(tokens: Tokens, rule: untyped): bool =
    tokens.next(rule).kind != Failure

# value

proc ValueRule(tokens: Tokens): Node
proc ExprRule(tokens: Tokens): Node
proc FileRule(tokens: Tokens): Node

proc ValueRule(tokens: Tokens): Node =
    if tokens.expect(NumLit, a):
        return a

    if tokens.expect("("):
        if tokens.expect(ExprRule, values):
            if tokens.expect(")"):
                return values

    if tokens.expect("["):
        if tokens.expect(ExprRule, value):
            if tokens.expect("]"):
                return value

    return fail()

proc ExprRule(tokens: Tokens): Node =
    if tokens.expect(ValueRule, a):
        if tokens.expect("+"):
            if tokens.expect(ExprRule, b):
                return newNode(@[ a, b ])
            return fail()
        return a
    return fail()

proc FileRule(tokens: Tokens): Node =
    if tokens.expect(ExprRule, value):
        if tokens.expect(EOF):
            return value
    
    return fail()

let tokens = @[
    (KeyWord, "("),
        (NumLit, "1"),
        (Ident, "+"),
        (NumLit, "2"),
    (KeyWord, ")"),
    (Ident, "+"),
    (NumLit, "3")
].Toks()

echo FileRule(tokens)