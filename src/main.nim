import strutils

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

iterator reverse*[T](a: seq[T]): (T, int) {.inline.} =
    var i = len(a) - 1
    while i > -1:
        yield ( a[i], i )
        dec(i)

proc body(node: Node): string =
    case node.kind
        of Terminal :
            return node.token.body
        else :
            return "ERROR"

proc tab(text: string): string =
    text.indent(1, "    ")

proc `\`(a, b: string): string =
    if b != "":
        a & "\n" & b
    else:
        a

template `\=`(a, b: string) =
    a = a \ b

proc ns(node: Node): seq[Node] =
    case node.kind
    of NonTerminal:
        return node.nodes
    else:
        echo "NS Error"
        return @[]

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

proc makeSteps(node: Node, nt: string, el: string): string
proc makeStep(node: Node, nt: string, el: string): string

proc makeLoop(node: Node, nt: string, el: string): string =
    var text = "let values = newSeq[Node]()"

    case node.kind
        of Terminal :
            text \= "for value := tokens.next(" & node.body & ") :"
            text \=     "values.add value".tab
        else :                
            text \= "while true :"
            
            var condition = "values.add value" \ "continue"

            for step, i in node.ns[0].ns.reverse:
                if i != 0 :
                    condition = makeStep(step, condition, "return fail('')")
                else:
                    condition = makeStep(step, condition, "break")

            text \= condition.tab()
    text \= nt

    return text
            

proc makeStep(node: Node, nt: string, el: string): string =
    case node.kind
        of Terminal :
            return
                "if tokens.next(" & node.body & ") :" \
                    nt.tab \
                el
        else :
            if node.ns[0].body == "*" :
                return makeLoop(node.ns[1], nt, el)
            
            if node.ns[0].body == "+" :
                return
                    "if tokens.mult(" & node.ns[1].body & ") :" \
                        nt.tab \
                    el

            if node.ns[0].body == "?" :
                return
                    "tokens.next(" & node.ns[1].body & ")" \
                    nt

            # return makeSteps(node, nt, "return")

proc makeSteps(node: Node, nt: string, el: string): string =
    var text = nt

    for step, i in node.ns.reverse:
        text = makeStep(step, text, el)

    return text

proc makeOpts(node: Node): string = 
    var text = "return fail('')"

    for opt, i in node.ns.reverse:
        text = makeSteps(opt, "return newNode(@[])", text)

    return text

proc makeFile(node: Node): string =
    var text = ""

    for rule in node.ns :
        text \= "proc " & rule.ns[0].body & "(tokens: Tokens): Node ="
        text \= makeOpts(rule.ns[1]).tab & "\n"

    return text

open("out.nim", fmWrite).write( makeFile( FileRule(tokens) ) )