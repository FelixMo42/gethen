import options

converter toBool*[T](a: Option[T]): bool = a.isSome()

type
    # token stuff

    TokenKind* = enum
        NAME
        STRING
        OPERATOR
        EOF

    Token* = tuple
        kind : TokenKind
        body : string

    Tokens* = ref object
        tokens* : seq[Token]
        index*  : int

    TokenOutOfBounds* = object of ValueError

    Rule[T] = proc (tokens: Tokens): Option[T]

# utility

iterator reverse*[T](a: seq[T]): (T, int) {.inline.} =
    var i = len(a) - 1
    while i > -1:
        yield ( a[i], i )
        dec(i)

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

proc next*(tokens: Tokens, body: string): Option[Token] =
    let token = tokens.peek()

    if token.body == body :
        tokens.next()

        return some(token)

    return none(Token)

proc next*(tokens: Tokens, kind: TokenKind): Option[Token] =
    let token = tokens.peek()

    if token.kind == kind :
        tokens.next()

        return some(token)

    return none(Token)

proc next*[T](tokens: Tokens, rule: Rule[T]): Option[T] =
    return rule(tokens)

# tmp

template `:=`*(a, b): bool =
    let a = b
    a

proc loop*[T](tokens: Tokens, rule: Rule[T]): Option[seq[T]] =
    var values = newSeq[T]()

    while value := tokens.next(rule):
        values.add( value )

    return some(values)

proc mult*[T](tokens: Tokens, rule: T): Option[seq[T]] =
    if value := tokens.next(rule) :
        var values = @[ value ]

        while value := tokens.next(rule):
            values.add( value )

        return some(values)

    return none(seq[T])