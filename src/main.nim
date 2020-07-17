import strutils
import source
import base
import options

# utility

const rf = "return none()"

proc tab(text: string): string =
    text.indent(1, "    ")

proc `\`(a, b: string): string = a & "\n" & b

template `\=`(a, b: string) =
    a = a \ b

proc procName(node: Node): string =
    node.ns[0].body #& "Rule"

proc nodeName(node: Node): string =
    node.ns[0].body & "Node"

proc isUpperCase(text: string): bool =
    for c in text:
        if not c.isUpperAscii() :
            return false
    return true

# rules

proc StepRule(tokens: Tokens): Node
proc OptsRule(tokens: Tokens): Node

proc AtomRule(tokens: Tokens): Node =
    if name := tokens.next(Ident):
        return name
    if name := tokens.next(StrLit):
        return name
    if tokens.next("("):
        if steps := tokens.next(OptsRule):
            if tokens.next(")"):
                return steps
    return fail("")

proc StepRule(tokens: Tokens): Node =
    proc tmp(tokens: Tokens): Node =
        if n := tokens.next(Ident):
            if tokens.next(":"):
                return n
        return fail("")

    let name = tokens.next(tmp)

    # echo name

    if atom := tokens.next(AtomRule):
        if op := tokens.next(Operator):
            return newNode(@[op, atom, name])
        return newNode(@[Node(kind: Terminal, token: (KeyWord, " ")), atom, name])
    return fail("expected expr")

proc OptsRule(tokens: Tokens): Node =
    if opt := tokens.mult(StepRule):
        var opts = @[ opt ]
        while true :
            if tokens.next("/"):
                if opt := tokens.mult(StepRule):
                    opts.add opt
                    continue
                return fail("expected expr")
            return newNode(opts)
    return fail("expected expr")

proc RuleRule(tokens: Tokens): Node =
    if tokens.next("@"):
        if name := tokens.next(Ident):
            if tokens.next("="):
                if opts := tokens.next(OptsRule):
                    return newNode(@[ name, opts ])
    return fail("expected expr")

proc FileRule(tokens: Tokens): Node =
    if value := tokens.loop(RuleRule):
        if tokens.next(EOF):
            return value
        return fail("expected eof")
    return fail("you get the gist")

#

proc makeSteps(node: Node, nt: string, el: string): string
proc makeStep(node: Node, name: char, nt: string, el: string): string
proc makeOpts(node: Node): string
proc getType(node: Node): string

proc makeStep(node: Node, name: char, nt: string, el: string): string =        
    let operator = node.ns[0].body
    var pattname = node.ns[1].body

    var text = ""

    if node.ns[1].kind == NonTerminal :
        text =
            "proc tmp(tokens: Tokens) : Node =" \
                makeOpts(node.ns[1]).tab \ ""

        pattname = "tmp"

    if operator == "*" :
        return text & 
            "let " & name & " = tokens.loop(" & pattname & ")" \
            nt
    
    if operator == "+" :
        return text &
            "if " & name & " := tokens.mult(" & pattname & ") :" \
                nt.tab \
            el

    if operator == "?" :
        return text & 
            "let " & name & " = tokens.next(" & pattname & ")" \
            nt

    if operator == " " :
        return text & 
            "if " & name & " := tokens.next(" & pattname & ") :" \
                nt.tab \
            el

proc makeSteps(node: Node, nt: string, el: string): string =
    var text = nt
    var name = 'a' 

    for step, i in node.ns.reverse:
        text = makeStep(step, name, text, el)

        inc(name)

    return text

proc makeOpts(node: Node): string = 
    var text = rf

    for opt, i in node.ns.reverse:
        text = makeSteps(opt, "return (@[])", text)
    
    return text

proc getType2(node: Node): string =
    case node.kind
        of Terminal :
            if node.token.kind == Ident :
                if node.token.body.isUpperCase:
                    return "Token"#node.token.body
                return node.token.body & "Node"
            else:
                return ""
        else :
            # echo node
            var ts = newSeq[string]()

            for opt in node.ns :
                for el in opt.ns :
                    let t = getType(el)

                    if t != "" :
                        ts.add t

            if ts.len == 1 :
                return ts[0]

            return "ERROR"
            
proc getType(node: Node): string =
    let op = node.ns[0].body

    if op == "*" : return "seq[" & getType2(node.ns[1]) & "]"
    if op == "+" : return "seq[" & getType2(node.ns[1]) & "]"
    if op == "?" : return "Option[" & getType2(node.ns[1]) & "]"
    if op == " " : return getType2(node.ns[1])

    return "ERROR"

proc makeType(node: Node): string =
    var text = "object"

    for opt in node.ns[1].ns :
        for el in opt.ns :
            if el.ns[2].kind == Terminal:
                text \= (el.ns[2].body & " : " & getType(el)).tab

    return text

proc makeFile(node: Node): string =
    var text =
        "import options" \
        "import tokens" \ ""

    text \= "type"
    for rule in node.ns :
        text \= (rule.nodeName & "* = " & makeType(rule)).tab \ ""

    for rule in node.ns :
        text \= "proc " & rule.procName & "*(tokens: Tokens): " & rule.nodeName
        
    text \= ""

    for rule in node.ns :
        text \= "proc " & rule.procName & "*(tokens: Tokens): " & rule.nodeName & " ="
        text \= makeOpts(rule.ns[1]).tab & "\n"

    return text

open("out.nim", fmWrite).write( makeFile(
    FileRule( Tokens(tokens: src, index: 0) )
) )