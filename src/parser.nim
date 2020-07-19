import options
import tokens
import ../psr/stream

type
    ValueKind* = enum 
        MakeFunc
        CallFunc
        Variable

    ParamNode = ref object
        name : string

    ValueNode* = ref object
        case kind* : ValueKind
        of MakeFunc :
            params : seq[ParamNode]
            value  : ValueNode
        of CallFunc :
            fn : ValueNode
            args : seq[ValueNode]
        of Variable :
            name : string

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

proc body*(node: Option[Token]): Option[string] =
    if node.isSome :
        return some(node.get.body)
    else :
        return none(string)

#

proc paramRule(tokens: Tokens): Option[ParamNode] =
    if a := tokens.next(Name) :
        return some(ParamNode(
            name : a.get.body
        ))
    return none(ParamNode)

proc valueRule(tokens: Tokens): Option[ValueNode] =
    var save =  tokens.save()

    if a := tokens.next(":") :
        let b = tokens.next(Name)
        if c := tokens.next("(") :
            let d = tokens.loop(paramRule)
            if e := tokens.next(")") :
                if f := tokens.next(valueRule) :
                    return some(ValueNode(
                        kind : MakeFunc
                    ))
    
    tokens.load(save)

    if a := tokens.next("(") :
        if b := tokens.next(valueRule) :
            let c = tokens.loop(valueRule)
            if d := tokens.next(")") :
                return some(ValueNode(
                    kind : CallFunc
                ))
    
    tokens.load(save)

    if a := tokens.next(Name) :
        return some(ValueNode(
            kind: Variable,
            name: a.get.body
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