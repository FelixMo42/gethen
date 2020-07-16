type
    # token stuff

    TokenKind = enum
        Ident
        Operator
        NumLit
        StrLit
        KeyWord
        EOF

    Token = tuple
        kind: TokenKind
        body: string

    Tokens = ref object
        tokens : seq[Token]
        index  : int

    TokenOutOfBounds = object of ValueError
        
    # node

    NodeKind = enum
        NonTerminal
        Terminal
        Failure

    Node = object
        case kind: NodeKind

        of Terminal :
            token : Token

        of NonTerminal :
            nodes : seq[Node]

        of Failure :
            msg : string

    #

    Rule = proc (tokens: Tokens) : Node

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
        kind  : NonTerminal,
        nodes : tokens
    )

proc fail(msg: string): Node =
    return Node(kind: Failure, msg: msg)

template `:=`(a,b): bool =
    let a = b
    a

converter toBool(a: Node): bool = a.kind != Failure

#

proc next(tokens: Tokens, body: string): Node =
    let token = tokens.peek()

    if token.body == body :
        tokens.next()

        return Node(kind: Terminal, token: token)

    return fail("1")

proc next(tokens: Tokens, kind: TokenKind): Node =
    let token = tokens.peek()

    if token.kind == kind :
        tokens.next()

        return Node(kind: Terminal, token: token)

    return fail("2")

proc next(tokens: Tokens, rule: Rule): Node =
    let save = tokens.save()

    let node = rule(tokens)

    if node.kind == Failure :
        tokens.load(save)

    return node

#

proc loop[T](tokens: Tokens, rule: T): Node =
    var values = newSeq[Node]()

    while value := tokens.next(rule):
        values.add( value )

    return Node( kind : NonTerminal, nodes : values )

proc mult[T](tokens: Tokens, rule: T): Node =
    if value := tokens.next(rule) :
        var values = @[ value ]

        while value := tokens.next(rule):
            values.add( value )

        return Node(
            kind : NonTerminal,
            nodes : values
        )

    return fail("")

# value

proc StepRule(tokens: Tokens): Node
proc OptsRule(tokens: Tokens): Node

proc AtomRule(tokens: Tokens): Node =
    if name := tokens.next(Ident):
        return name
    if name := tokens.next(StrLit):
        return name
    if tokens.next("("):
        if steps := tokens.next(OptsRule):
            if tokens.next(")"):
                return steps
    return fail("")

proc StepRule(tokens: Tokens): Node =
    if atom := tokens.next(AtomRule):
        if op := tokens.next(Operator):
            return newNode(@[op, atom])
        return atom
    return fail("expected expr")

proc OptsRule(tokens: Tokens): Node =
    if opt := tokens.mult(StepRule):
        var opts = @[ opt ]
        while true :
            if tokens.next("/"):
                if opt := tokens.mult(StepRule):
                    opts.add opt
                    continue
                return fail("expected expr")
            return newNode(opts)
    return fail("expected expr")

proc RuleRule(tokens: Tokens): Node =
    if tokens.next("@"):
        if name := tokens.next(Ident):
            if tokens.next("="):
                if opts := tokens.next(OptsRule):
                    return newNode(@[ name, opts ])
    return fail("expected expr")

proc FileRule(tokens: Tokens): Node =
    if value := tokens.loop(RuleRule):
        if tokens.next(EOF):
            return value
        return fail("expected eof")
    return fail("you get the gist")

let tokens = @[
    (KeyWord, "@"),
    (Ident, "atom"),
    (KeyWord, "="),
        (Ident, "NAME"),
        (KeyWord, "/"),
        (Ident, "STRING"),
        (KeyWord, "/"),
        (StrLit, "'('"),
        (Ident, "opts"),
        (StrLit, "')'"),

    (KeyWord, "@"),
    (Ident, "step"),
    (KeyWord, "="),
        (Ident, "step"),
        (Ident, "OP"),
        (Operator, "?"),

    (KeyWord, "@"),
    (Ident, "opts"),
    (KeyWord, "="),
        (Ident, "step"),
        (Operator, "+"),
        (KeyWord, "("),
            (StrLit, "'/'"),
            (Ident, "step"),
            (Operator, "+"),
        (KeyWord, ")"),
        (Operator, "*"),

    (KeyWord, "@"),
    (Ident, "rule"),
    (KeyWord, "="),
        (StrLit, "'@'"),
        (Ident, "NAME"),
        (StrLit, "'='"),
        (Ident, "opts"),

    (KeyWord, "@"),
    (Ident, "file"),
    (KeyWord, "="),
        (Ident, "rule"),
        (Operator, "*"),
        (Ident, "EOF")
].Toks()

proc body(node: Node): string =
    case node.kind
        of Terminal :
            return node.token.body
        else :
            return "ERROR"
#

proc makeStep(node: Node, tab: string) =
    case node.kind
        of Terminal :
            echo tab, "if ", node.body ," :"
        else :
            if node.nodes[0].body == "*" :
                echo tab, "if ", node.nodes[1].body, " :"
            
            if node.nodes[0].body == "+" :
                echo tab, "for ", node.nodes[1].body, " :"

            if node.nodes[0].body == "?" :
                echo tab, "for ", node.nodes[1].body, " :"
            

proc makeOpts(node: Node, tab: string) = 
    for opt in node.nodes:
        makeStep(opt.nodes[0], tab)

    echo tab, "return fail('')"

proc makeFile(node: Node) =
    for rule in node.nodes :
        echo "proc ", rule.nodes[0].body, "(tokens: Tokens): Node ="

        makeOpts(rule.nodes[1], "\t")

        echo ""

    # case node.kind:

    # of NonTerminal :
    #     for node in node.nodes:
    #         print(node, tab & "  ")

    # of Terminal :
    #     echo tab & node.token.body

    # of Failure :
    #     echo tab & "failure: " & node.msg

makeFile( FileRule(tokens) )