import options
import tokens

type
    FileNode* = object
        rules* : seq[RuleNode]

    RuleNode* = object
        name* : string
        opts* : OptsNode

    OptsNode* = seq[seq[StepNode]]

    StepNode* = object
        name* : Option[string]
        pattern* : AtomNode
        operator* : string

    AtomKind* = enum
        NAME,
        BODY,
        OPTS

    AtomNode* = object
        case kind* : AtomKind
            of NAME, BODY:
                data*: string
            of OPTS:
                opts*: OptsNode

proc file(tokens: Tokens): Option[FileNode]
proc rule(tokens: Tokens): Option[RuleNode]
proc opts(tokens: Tokens): Option[OptsNode]
proc step(tokens: Tokens): Option[StepNode]
proc atom(tokens: Tokens): Option[AtomNode]

proc file(tokens: Tokens): Option[FileNode] =
    if b := tokens.loop(rule) :
        if a := tokens.next(EOF) :
            return some(FileNode(
                rules : b.get,
            ))
        return none(FileNode)

proc rule(tokens: Tokens): Option[RuleNode] =
    if d := tokens.next("@") :
        if c := tokens.next(Ident) :
            if b := tokens.next("=") :
                if a := tokens.next(opts) :
                    return some(RuleNode(
                        opts : a.get,
                        name : c.get.body,
                    ))
                return none(RuleNode)
            return none(RuleNode)
        return none(RuleNode)
    return none(RuleNode)

proc opts(tokens: Tokens): Option[OptsNode] =
    if b := tokens.mult(step) :
        var steps = @[ b.get ]
        proc tmp(tokens: Tokens): Option[int] =
            if b := tokens.next("/") :
                if a := tokens.mult(step) :
                    steps.add(a.get)
                    return some(1)
                return none(int)
            return none(int)

        if a := tokens.loop(tmp) :
            return some(OptsNode(steps))
    return none(OptsNode)

proc step(tokens: Tokens): Option[StepNode] =
    proc tmp(tokens: Tokens) : Option[Token] =
        if b := tokens.next(Ident) :
            if a := tokens.next(":") :
                return b
            return none(Token)
        return none(Token)
    let c = tokens.next(tmp)
    if b := tokens.next(atom) :
        let a = tokens.next(Operator)
        return some(StepNode(
            operator : a.get((Ident, " ")).body,
            pattern : b.get,
            name : c.body,
        ))
    return none(StepNode)

proc atom(tokens: Tokens): Option[AtomNode] =
    if a := tokens.next(Ident) :
        return some(AtomNode(
            kind : NAME,
            data : a.get.body
        ))
    if a := tokens.next(StrLit) :
        return some(AtomNode(
            kind : BODY,
            data : a.get.body
        ))
    if c := tokens.next("(") :
        if b := tokens.next(opts) :
            if a := tokens.next(")") :
                return some(AtomNode(
                    kind : OPTS,
                    opts : b.get
                ))
            return none(AtomNode)
        return none(AtomNode)
    return none(AtomNode)

const parse* = file