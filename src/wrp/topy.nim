import ../psr/parser
import strformat
import sequtils
import strutils
import sugar

const comma = ", "

type Script = ref object
    funcs : seq[string]
    names : char

proc tab(txt: string) : string = txt.indent(1, "   ")

proc newScript(): Script = 
    return Script(funcs: newSeq[string](), names: 'a')

proc make*(node: ValueNode, script: Script): string =
    case node.kind :
    of MakeFunc :
        # get an unused function name
        let name = script.names

        # move on to next func name
        inc(script.names)

        # add the function to the list of functions for this scope
        script.funcs.add(
            &"def {name}({node.params.map(n => n.name.body).join(comma)}) :\n" &
            ("return " & make(node.value, script)).tab()
        )

        # return the name of the functions
        return name & ""
    of CallFunc :
        let fn = make(node.fn, script)

        if fn == "+": 
            return &"({make(node.args[0], script)} + {make(node.args[1], script)})"

        return &"{fn}({node.args.map(n => make(n, script)).join(comma)})"
    of Variable :
        return node.name
    of StrValue :
        return &"\"{node.strv}\""
    of IntValue :
        return $node.intv

proc toPy*(node: ValueNode): string =
    var script = newScript()

    let root = make(node, script)

    return script.funcs.join("\n ") & "\n\n" &  &"print({root})"