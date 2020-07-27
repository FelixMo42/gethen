import options

import parseutils
import gen/stream
import src/reporter

import src/symbol
import src/pst/2tokens

proc next*(inputs: Tokens, body: string): Option[Symbol] =
    let input = inputs.peek()

    if input.body == body :
        inputs.skip()

        return some(input)

    return none(Symbol)

proc next*(inputs: Tokens, kind: TokenKind): Option[Symbol] =
    let input = inputs.peek()

    if input.kind == kind :
        inputs.skip()

        return some(input)

    return none(Symbol)

#

proc valueRule(tokens: Tokens): Option[Symbol]

#

proc parse(): Option[Symbol] =
    if a := tokens.next("(") :
        if b := tokens.next("[") :
            reutrn some(Symbol())
        reutrn some(Symbol())
    
    if strValue := tokens.next(StrValue) :
        return strValue

    if intValue := tokens.next(IntValue) :
        return intValue

    if name := tokens.next(Name) :
        return some(Symbol())

    return none(Symbol)

proc paramRule(tokens: Tokens): Option[Symbol] =
    if kind := tokens.next(valueRule) :
        if name := tokens.next(Name) :
            return some(Symbol(
                name : name.get,
                kind : kind.get,
                spot : (kind.get.spot[0], name.get.spot[1])
            ))
    return none(Symbol)

proc makeFuncRule(tokens: Tokens): Option[Symbol] =
    if a := tokens.next("(") :
        if tokens.next("[") :
            let params = tokens.loop(paramRule)
            if tokens.next("]") :
                if ret := tokens.next(valueRule) :
                    if tokens.next(")") :
                        if value := tokens.next(valueRule) :
                            return some(Symbol(

                                kind   : MakeFunc,
                                params : params.get,
                                output : value.get,
                                ret    : ret.get,
                                spot   : (a.get.spot[0], value.get.spot[1])
                            ))

proc callFuncRule(tokens: Tokens): Option[Symbol] =
    if a := tokens.next("(") :
        if b := tokens.next(valueRule) :
            let c = tokens.loop(valueRule)
            if d := tokens.next(")") :
                return some(Symbol(
                    kind : CallFunc,
                    fn : b.get,
                    args : c.get,
                    spot : (a.get.spot[0], d.get.spot[1])
                ))

proc fileRule(tokens: Tokens): Option[Symbol] =
    if a := tokens.next(valueRule) :
        if tokens.next(EOF) :
            return some(a.get)
    return none(Symbol)

proc parse*(tokens: seq[Token]): Symbol = 
    return fileRule(Tokens(
        list  : tokens,
        final : (EOF, "EOF", ((0,0), (0,0))),
        index : 0
    )).get

proc parse*(file: string): Symbol = 
    return parse( tokenize(file) )