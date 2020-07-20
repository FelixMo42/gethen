import options
import tokens
import ../../gen/stream

type
    ParamNode = ref object
        name* : string
        kind* : ValueNode

    ValueKind* = enum 
        MakeFunc
        CallFunc
        Variable

        StrValue
        IntValue

    ValueNode* = ref object
        case kind* : ValueKind
        of MakeFunc :
            params* : seq[ParamNode]
            value*  : ValueNode
            ret*    : ValueNode
        of CallFunc :
            fn* : ValueNode
            args* : seq[ValueNode]
        of Variable :
            name* : string
        of StrValue :
            strv* : string
        of IntValue :
            intv* : int

#        

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
                name : name.get.body,
                kind : kind.get
            ))
    return none(ParamNode)

proc valueRule(tokens: Tokens): Option[ValueNode] =
    var save = tokens.save()

    if tokens.next("(") :
        if tokens.next("[") :
            let params = tokens.loop(paramRule)
            if tokens.next("]") :
                if ret := tokens.next(valueRule) :
                    if tokens.next(")") :
                        if value := tokens.next(valueRule) :
                            return some(ValueNode(
                                kind  : MakeFunc,
                                params : params.get,
                                value  : value.get,
                                ret    : ret.get
                            ))
    
    tokens.load(save)

    if a := tokens.next("(") :
        if b := tokens.next(valueRule) :
            let c = tokens.loop(valueRule)
            if d := tokens.next(")") :
                return some(ValueNode(
                    kind : CallFunc,
                    fn : b.get,
                    args : c.get
                ))
    
    tokens.load(save)

    if a := tokens.next(Name) :
        return some(ValueNode(
            kind: Variable,
            name: a.get.body
        ))

    if a := tokens.next(StrLit) :
        return some(ValueNode(
            kind: StrValue,
            strv: a.get.body
        ))
    
    return none(ValueNode)

proc fileRule(tokens: Tokens): Option[ValueNode] =
    if a := tokens.next(valueRule) :
        if b := tokens.next(EOF) :
            return some(a.get)
    return none(ValueNode)

proc parse*(tokens: seq[Token]): ValueNode = 
    return fileRule(Tokens(
        list  : tokens,
        final : (EOF, "EOF"),
        index : 0
    )).get

proc parse*(file: string): ValueNode = 
    return parse( tokenize(file) )