import options
import tokens

type
    atomNode* = object

    stepNode* = object
        name : Option[Token]
        pattern : atomNode
        operator : Option[Token]

    optsNode* = object
        steps : seq[stepNode]
        steps : seq[seq[stepNode]]

    ruleNode* = object
        name : 
        opts : 

    fileNode* = object
        rules : seq[ruleNode]

proc atom*(tokens: Tokens): atomNode
proc step*(tokens: Tokens): stepNode
proc opts*(tokens: Tokens): optsNode
proc rule*(tokens: Tokens): ruleNode
proc file*(tokens: Tokens): fileNode

proc atom*(tokens: Tokens): atomNode =
    if a := tokens.next(NAME) :
        return (@[])
    if a := tokens.next(STRING) :
        return (@[])
    if c := tokens.next("(") :
        if b := tokens.next(opts) :
            if a := tokens.next(")") :
                return (@[])
            return none()
        return none()
    return none()

proc step*(tokens: Tokens): stepNode =
    proc tmp(tokens: Tokens) : Node =
        if b := tokens.next(NAME) :
            if a := tokens.next(":") :
                return (@[])
            return none()
        return none()
    let c = tokens.next(tmp)
    if b := tokens.next(atom) :
        let a = tokens.next(OPERATOR)
        return (@[])
    return none()

proc opts*(tokens: Tokens): optsNode =
    if b := tokens.mult(step) :
        proc tmp(tokens: Tokens) : Node =
            if b := tokens.next("/") :
                if a := tokens.mult(step) :
                    return (@[])
                return none()
            return none()
        let a = tokens.loop(tmp)
        return (@[])
    return none()

proc rule*(tokens: Tokens): ruleNode =
    if d := tokens.next("@") :
        if c := tokens.next(NAME) :
            if b := tokens.next("=") :
                if a := tokens.next(opts) :
                    return (@[])
                return none()
            return none()
        return none()
    return none()

proc file*(tokens: Tokens): fileNode =
    let b = tokens.loop(rule)
    if a := tokens.next(EOF) :
        return (@[])
    return none()
