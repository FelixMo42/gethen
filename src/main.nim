type
    TokenKind = enum 
        Ident,
        NumLit,
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

proc skip*(tokens: Tokens) =
    tokens.index += 1

proc read*(tokens: Tokens): Token =
    # get the current token
    let token = tokens.peek()

    # increment are location in the list
    tokens.skip()

    # return the current token
    return token

proc save*(tokens: Tokens): int =
    return tokens.index

proc load*(tokens: Tokens, index: int) =
    tokens.index = index

# parse function

template expect*(tokens: Tokens, value: string, name: untyped, next: untyped) =
    let token = tokens.peek()

    if token.body == value :
        let name = Node(
            terminal : true,
            node : tokens.read()
        )

        next

template expect*(tokens: Tokens, value: string, next: untyped) =
    let token = tokens.peek()

    if token.body == value :
        tokens.skip()

        next

template expect*(tokens: Tokens, value: TokenKind, name: untyped, next: untyped) =
    let token = tokens.peek()

    if token.kind == value :
        let name = Node(
            kind : Terminal,
            node : tokens.read()
        )

        next

template expect*(tokens: Tokens, value: TokenKind, next: untyped) =
    let token = tokens.peek()

    if token.kind == value :
        tokens.skip()

        next

template expect*(tokens: Tokens, rule: Rule, name: untyped, next: untyped) =
    let index = tokens.save()

    let ast = rule(tokens)

    if ast.kind != Failure :
        let name = ast

        next

    tokens.load(index)

template expect*(tokens: Tokens, rule: Rule, next: untyped) =
    let index = tokens.save()

    let ast = rule(tokens)

    if ast.len != Failure :
        next

    tokens.load(index)

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

# value

proc ValueRule(tokens: Tokens): Node
proc ExprRule(tokens: Tokens): Node
proc FileRule(tokens: Tokens): Node

proc ValueRule(tokens: Tokens): Node =
    tokens.expect(NumLit, a):
        return a

    tokens.expect("("):
        tokens.expect(ExprRule, value):
            tokens.expect(")"):
                return value

    return fail()

proc ExprRule(tokens: Tokens): Node =
    tokens.expect(ValueRule, a):
        tokens.expect("+"):
            tokens.expect(ValueRule, b):
                return newNode(@[ a, b ])
        
    return fail()

proc FileRule(tokens: Tokens): Node =
    tokens.expect(ExprRule, value):
        tokens.expect(EOF):
            return value
    
    return fail()

let tokens = @[ (NumLit, "1"), (Ident, "+"), (NumLit, "1") ].Toks()

echo FileRule(tokens)