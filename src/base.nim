type
    # token stuff

    TokenKind* = enum
        Ident
        Operator
        NumLit
        StrLit
        KeyWord
        EOF

    Token* = tuple
        kind : TokenKind
        body : string

    Tokens* = ref object
        tokens* : seq[Token]
        index*  : int

    TokenOutOfBounds* = object of ValueError
        
    # node

    NodeKind* = enum
        NonTerminal
        Terminal
        Failure

    Node* = object
        case kind*: NodeKind

        of Terminal :
            token* : Token

        of NonTerminal :
            nodes* : seq[Node]

        of Failure :
            msg* : string

    #

    Rule* = proc (tokens: Tokens) : Node

# utility

proc newNode*(tokens: seq[Node]): Node =
    return Node(
        kind  : NonTerminal,
        nodes : tokens
    )

proc fail*(msg: string): Node =
    return Node(kind: Failure, msg: msg)

template `:=`*(a,b): bool =
    let a = b
    a

converter toBool*(a: Node): bool = a.kind != Failure

iterator reverse*[T](a: seq[T]): (T, int) {.inline.} =
    var i = len(a) - 1
    while i > -1:
        yield ( a[i], i )
        dec(i)

proc body*(node: Node): string =
    case node.kind
        of Terminal :
            return node.token.body
        else :
            return "ERROR"

proc tokKind*(node: Node): TokenKind =
    case node.kind
        of Terminal :
            return node.token.kind
        else :
            raise newException(ValueError, "no know kind")

proc ns*(node: Node): seq[Node] =
    case node.kind
    of NonTerminal:
        return node.nodes
    else:
        echo "NS Error"
        return @[]

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

proc next*(tokens: Tokens, body: string): Node =
    let token = tokens.peek()

    if token.body == body :
        tokens.next()

        return Node(kind: Terminal, token: token)

    return fail("1")

proc next*(tokens: Tokens, kind: TokenKind): Node =
    let token = tokens.peek()

    if token.kind == kind :
        tokens.next()

        return Node(kind: Terminal, token: token)

    return fail("2")

proc next*(tokens: Tokens, rule: Rule): Node =
    let save = tokens.save()

    let node = rule(tokens)

    if node.kind == Failure :
        tokens.load(save)

    return node

# tmp

proc loop*[T](tokens: Tokens, rule: T): Node =
    var values = newSeq[Node]()

    while value := tokens.next(rule):
        values.add( value )

    return Node( kind : NonTerminal, nodes : values )

proc mult*[T](tokens: Tokens, rule: T): Node =
    if value := tokens.next(rule) :
        var values = @[ value ]

        while value := tokens.next(rule):
            values.add( value )

        return Node(
            kind : NonTerminal,
            nodes : values
        )

    return fail("")