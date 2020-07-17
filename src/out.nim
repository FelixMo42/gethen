import options
import tokens

type
    fileNode* = object
        rules : seq[ruleNode]

    ruleNode* = object
        name : Token
        opts : optsNode

    optsNode* = object
        steps : seq[stepNode]
        steps : seq[seq[stepNode]]

    stepNode* = object
        name : Option[Token]
        pattern : atomNode
        operator : Option[Token]

    atomNode* = object

proc file*(tokens: Tokens): Option[fileNode]
proc rule*(tokens: Tokens): Option[ruleNode]
proc opts*(tokens: Tokens): Option[optsNode]
proc step*(tokens: Tokens): Option[stepNode]
proc atom*(tokens: Tokens): Option[atomNode]

proc file*(tokens: Tokens): Option[fileNode] =
    if b := tokens.loop(rule) :
        if a := tokens.next(EOF) :
            return some(fileNode(
                rules : b.get,
            ))
        return none(fileNode)

proc rule*(tokens: Tokens): Option[ruleNode] =
    if d := tokens.next("@") :
        if c := tokens.next(NAME) :
            if b := tokens.next("=") :
                if a := tokens.next(opts) :
                    return some(ruleNode(
                        opts : a.get,
                        name : c.get,
                    ))
                return none(ruleNode)
            return none(ruleNode)
        return none(ruleNode)
    return none(ruleNode)

proc opts*(tokens: Tokens): Option[optsNode] =
    if b := tokens.mult(step) :
        proc tmp(tokens: Tokens) : Option[] =
            if b := tokens.next("/") :
                if a := tokens.mult(step) :
                    return some((
                    ))
                return none()
            return none()
        if a := tokens.loop(tmp) :
            return some(optsNode(
                steps : a.get,
                steps : b.get,
            ))
    return none(optsNode)

proc step*(tokens: Tokens): Option[stepNode] =
    proc tmp(tokens: Tokens) : Option[] =
        if b := tokens.next(NAME) :
            if a := tokens.next(":") :
                return some((
                ))
            return none()
        return none()
    let c = tokens.next(tmp)
    if b := tokens.next(atom) :
        let a = tokens.next(OPERATOR)
        return some(stepNode(
            operator : a.get,
            pattern : b.get,
            name : c.get,
        ))
    return none(stepNode)

proc atom*(tokens: Tokens): Option[atomNode] =
    if a := tokens.next(NAME) :
        return some(atomNode(
        ))
    if a := tokens.next(STRING) :
        return some(atomNode(
        ))
    if c := tokens.next("(") :
        if b := tokens.next(opts) :
            if a := tokens.next(")") :
                return some(atomNode(
                ))
            return none(atomNode)
        return none(atomNode)
    return none(atomNode)
