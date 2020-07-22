import ../psr/parser
import strformat
import sequtils
import strutils

const comma = ", "

proc toJs(node: ParamNode): string =
    return node.name

proc toJs*(node: ValueNode): string =
    case node.kind :
    of MakeFunc :
        return &"(({node.params.map(toJs).join(comma)}) => {toJs(node.value)})"
    of CallFunc :
        let fn = toJs(node.fn)

        if fn == "+": 
            return &"({toJs(node.args[0])} + {toJs(node.args[1])})"

        return &"{fn}({node.args.map(toJs).join(comma)})"
    of Variable :
        return node.name
    of StrValue :
        return &"\"{node.strv}\""
    of IntValue :
        return $node.intv