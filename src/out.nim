import base
import options

type
    atomNode* = object
        a : NAME
        a : STRING
        a : optsNode

    stepNode* = object
        a : Option[NAME]
        a : stepNode
        a : Option[OP]

    optsNode* = object
        a : seq[stepNode]
        a : seq[seq[stepNode]]

    ruleNode* = object
        a : NAME
        a : optsNode

    fileNode* = object
        a : seq[ruleNode]
        a : EOF

proc atom*(tokens: Tokens): atomNode
proc step*(tokens: Tokens): stepNode
proc opts*(tokens: Tokens): optsNode
proc rule*(tokens: Tokens): ruleNode
proc file*(tokens: Tokens): fileNode

proc atom*(tokens: Tokens): atomNode =
    if tokens.next(NAME) :
        return newNode(@[])
    if tokens.next(STRING) :
        return newNode(@[])
    if tokens.next('(') :
        if tokens.next(opts) :
            if tokens.next(')') :
                return newNode(@[])
            return fail("")
        return fail("")
    return fail("")

proc step*(tokens: Tokens): stepNode =
    proc tmp(tokens: Tokens) : Node =
        if tokens.next(NAME) :
            if tokens.next(':') :
                return newNode(@[])
            return fail("")
        return fail("")
    
    tokens.next(tmp)
    if tokens.next(step) :
        tokens.next(OP)
        return newNode(@[])
    return fail("")

proc opts*(tokens: Tokens): optsNode =
    if tokens.mult(step) :
        proc tmp(tokens: Tokens) : Node =
            if tokens.next('/') :
                if tokens.mult(step) :
                    return newNode(@[])
                return fail("")
            return fail("")
        
        if tokens.loop(tmp) :
            return newNode(@[])
    return fail("")

proc rule*(tokens: Tokens): ruleNode =
    if tokens.next('@') :
        if tokens.next(NAME) :
            if tokens.next('=') :
                if tokens.next(opts) :
                    return newNode(@[])
                return fail("")
            return fail("")
        return fail("")
    return fail("")

proc file*(tokens: Tokens): fileNode =
    if tokens.loop(rule) :
        if tokens.next(EOF) :
            return newNode(@[])
        return fail("")
