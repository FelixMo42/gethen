import options
import parseutils
import ../../gen/stream
import ../report
import tokens

type
    ParamNode* = ref object
        name* : string
        kind* : ValueNode
        spot* : Spot

    ValueKind* = enum 
        MakeFunc
        CallFunc
        Variable

        StrValue
        IntValue

    ValueNode* = ref object
        spot* : Spot
        case kind* : ValueKind
        of MakeFunc :
            params* : seq[ParamNode]
            output* : ValueNode
            ret*    : ValueNode
        of CallFunc :
            fn* : ValueNode
            args* : seq[ValueNode]
        of Variable :
            name* : Token
        of StrValue :
            strv* : string
        of IntValue :
            intv* : int

#        


converter toSpot*(token: Token): Spot = token.spot
converter toSpot*(node: ValueNode): Spot = node.spot
converter toString*(token: Token): string = token.body

proc next*(inputs: Tokens, body: string): Option[Token] =
    let input = inputs.peek()

    if input.body == body :
        inputs.skip()

        return some(input)

    return none(Token)

proc next*(inputs: Tokens, kind: TokenKind): Option[Token] =
    let input = inputs.peek()

    if input.kind == kind :
        inputs.skip()

        return some(input)

    return none(Token)

#

proc valueRule(tokens: Tokens): Option[ValueNode]

#

proc paramRule(tokens: Tokens): Option[ParamNode] =
    if kind := tokens.next(valueRule) :
        if name := tokens.next(Name) :
            return some(ParamNode(
                name : name.get,
                kind : kind.get,
                # spot : 
            ))
    return none(ParamNode)

proc valueRule(tokens: Tokens): Option[ValueNode] =
    var save = tokens.save()

    if a := tokens.next("(") :
        if tokens.next("[") :
            let params = tokens.loop(paramRule)
            if tokens.next("]") :
                if ret := tokens.next(valueRule) :
                    if tokens.next(")") :
                        if value := tokens.next(valueRule) :
                            return some(ValueNode(
                                kind   : MakeFunc,
                                params : params.get,
                                output : value.get,
                                ret    : ret.get,
                                spot   : (a.get.spot[0], value.get.spot[1])
                            ))
    
    tokens.load(save)

    if a := tokens.next("(") :
        if b := tokens.next(valueRule) :
            let c = tokens.loop(valueRule)
            if d := tokens.next(")") :
                return some(ValueNode(
                    kind : CallFunc,
                    fn : b.get,
                    args : c.get,
                    spot : (a.get.spot[0], d.get.spot[1])
                ))
    
    tokens.load(save)

    if a := tokens.next(StrLit) :
        return some(ValueNode(
            kind : StrValue,
            strv : a.get.body,
            spot : a.get.spot
        ))

    if a := tokens.next(IntLit) :
        var num : int
        let res = parseInt(a.get.body, num)
        if res != 0 :
            return some(ValueNode(
                kind: IntValue,
                intv: num,
                spot: a.get.spot
            )) 
        else :
            fail a.get.spot, "int overflow!"
            return some(ValueNode(
                kind: IntValue,
                intv: 0,
                spot: a.get.spot
            )) 

    if a := tokens.next(Name) :
        return some(ValueNode(
            kind: Variable,
            name: a.get,
            spot: a.get.spot
        ))
    
    return none(ValueNode)

proc fileRule(tokens: Tokens): Option[ValueNode] =
    if a := tokens.next(valueRule) :
        if tokens.next(EOF) :
            return some(a.get)
    return none(ValueNode)

proc parse*(tokens: seq[Token]): ValueNode = 
    return fileRule(Tokens(
        list  : tokens,
        final : (EOF, "EOF", ((0,0), (0,0))),
        index : 0
    )).get

proc parse*(file: string): ValueNode = 
    return parse( tokenize(file) )