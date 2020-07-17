
proc atom(tokens: Tokens): Node =
    if tokens.next(NAME) :
        return newNode(@[])
    if tokens.next(STRING) :
        return newNode(@[])
    if tokens.next('(') :
        if tokens.next(opts) :
            if tokens.next(')') :
                return newNode(@[])
            return fail('')
        return fail('')
    return fail('')

proc step(tokens: Tokens): Node =
    if tokens.next(step) :
        tokens.next(OP)
        return newNode(@[])
    return fail('')

proc opts(tokens: Tokens): Node =
    if tokens.mult(step) :
        let values = newSeq[Node]()
        while true :
            if tokens.next('/') :
                if tokens.mult(step) :
                    values.add value
                    continue
                return fail('')
            break
        return newNode(@[])
    return fail('')

proc rule(tokens: Tokens): Node =
    if tokens.next('@') :
        if tokens.next(NAME) :
            if tokens.next('=') :
                if tokens.next(opts) :
                    return newNode(@[])
                return fail('')
            return fail('')
        return fail('')
    return fail('')

proc file(tokens: Tokens): Node =
    let values = newSeq[Node]()
    for value := tokens.next(rule) :
        values.add value
    if tokens.next(EOF) :
        return newNode(@[])
    return fail('')
