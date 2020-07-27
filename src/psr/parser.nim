import options
import gen/stream
import position
import tokens

type
    ParamNode* = ref object
        name* : Token
        kind* : ValueNode
        spot* : Position

    ValueKind* = enum 
        MakeFunc
        CallFunc
        Variable
        StrValue
        IntValue

    ValueNode* = ref object
        spot* : Position
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
        of StrValue , IntValue :
            value* : string

    Tokens = Inputs[Token]

#

converter toSpot*(token: Token): Position = token.spot
converter toSpot*(node: ValueNode): Position = node.spot

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
                spot : (kind.get.spot[0], name.get.spot[1])
            ))

proc makeFuncRule(tokens: Tokens): Option[ValueNode] =
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

proc callFuncRule(tokens: Tokens): Option[ValueNode] =
    if a := tokens.next("(") :
        if b := tokens.next(valueRule) :
            let c = tokens.loop(valueRule)
            if d := tokens.next(")") :
                return some(ValueNode(
                    kind : CallFunc,
                    fn   : b.get,
                    args : c.get,
                    spot : (a.get.spot[0], d.get.spot[1])
                ))

proc valueRule(tokens: Tokens): Option[ValueNode] =
    var save = tokens.save()

    if node := tokens.next(makeFuncRule) :
        return node

    if node := tokens.next(callFuncRule) :
        return node

    if token := tokens.next(StrLit) :
        return some(ValueNode(
            kind : StrValue,
            value : token.get.body,
            spot : token.get.spot
        ))

    if token := tokens.next(NumLit) :
        return some(ValueNode(
            kind : IntValue,
            value : token.get.body,
            spot : token.get.spot
        ))

    if token := tokens.next(Name) :
        return some(ValueNode(
            kind : Variable,
            name : token.get,
            spot : token.get.spot
        ))

proc fileRule(tokens: Tokens): Option[ValueNode] =
    if a := tokens.next(valueRule) :
        # if tokens.next(EOF) :
            return some(a.get)

proc parse*(tokens: seq[Token]): ValueNode = 
    return fileRule(Tokens(
        list  : tokens,
        index : 0
    )).get

proc parse*(file: string): ValueNode = 
    return parse( tokenize(file) )