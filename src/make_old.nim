import strutils
import source
import base

# utility

iterator sub(node: Node): Node {.inline.} =
    let a = node.ns
    var i = len(a) - 1
    while i > -1:
        yield a[i]
        dec(i)

iterator steps(node: Node): (Node, char) {.inline.} =
    var name = 'a'
    for sub in node.sub:
        yield (sub, name)
        inc(name)

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

proc makeStep(node: Node, name: char, nt: string, el: string): string
proc makeOpts(node: Node, name: string): string
proc getType(node: Node): string
proc makeTouple(node: Node): string

proc makeStep(node: Node, name: char, nt: string, el: string): string =        
    let operator = node.ns[0].body
    var pattname = node.ns[1].body

    var text = ""

    if node.ns[1].kind == NonTerminal :
        echo "\n\n", node.ns[1]
        # makeTouple(node.ns[1])
        var tp = ""

        text =
            "proc tmp(tokens: Tokens) : Option[" & tp & "] =" \
                makeOpts(node.ns[1], tp).tab \ ""

        pattname = "tmp"

    if operator == "*" :
        return text & 
            "if " & name & " := tokens.loop(" & pattname & ") :" \
                nt.tab
    
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

proc makeSteps(node: Node, typeName, el: string): string =
    var text = "return some(" & typeName & "("
    for step, name in node.steps:
        if step.ns[2].kind == Terminal :
            text \= (step.ns[2].body & " : " & name & ".get,").tab
    text \= "))"

    for step, name in node.steps:
        text = makeStep(step, name, text, el)

    return text

proc makeOpts(node: Node, name: string): string = 
    var text = "return none(" & name & ")"

    for opt in node.sub:
        text = makeSteps(opt, name, text)
    
    return text

proc makeWrap(tp, op: string): string =
    if op == "*" : return "seq[" & tp & "]"
    if op == "+" : return "seq[" & tp & "]"
    if op == "?" : return "Option[" & tp & "]"
    if op == " " : return tp

proc makeTouple(node: Node): string =
    case node.kind
        of Terminal :
            if node.token.kind == Ident :
                if node.token.body.isUpperCase:
                    return "Token"
                return node.token.body & "Node"
            else:
                return ""
        of NonTerminal :
            var els = newSeq[string]()
            for el in node.sub :
                let op = el.ns[0].body
                let tp = makeTouple(el.ns[1]).makeWrap(op)

                if (el.ns[2].kind == Terminal):
                    els &= el.ns[2].body & " : " & tp

                if (tp != ""):
                    els &= tp

            if els.len == 0 :
                return ""
            if els.len == 1 :
                return els[0]
            else:
                return "(" & els.join(",") & ")"
        of Failure :
            return "ERROR2"

proc getType(node: Node): string =
    case node.kind
        of Terminal :
            if node.token.kind == Ident :
                if node.token.body.isUpperCase:
                    return "Token"
                return node.token.body & "Node"
            else:
                return ""
        of NonTerminal :
            # echo node
            var ts = newSeq[string]()

            for opt in node.sub :
                let t = makeTouple(opt)

                if t != "()" :
                    ts.add t

            if ts.len == 1 :
                return ts[0]

            return "ERROR"
        of Failure :
            return ""

proc makeType(node: Node): string =
    var text = "object"

    for opt in node.ns[1].ns :
        for el in opt.ns :
            if el.ns[2].kind == Terminal:
                let op = el.ns[0].body
                let tp = getType(el.ns[1]).makeWrap(op)
                let name = el.ns[2].body

                text \= (name & " : " & tp).tab

    return text

proc makeFile(node: Node): string =
    var text =
        "import options" \
        "import tokens" \ ""

    text \= "type"
    for rule in node.sub :
        text \= (rule.nodeName & "* = " & makeType(rule)).tab \ ""

    for rule in node.sub :
        text \= "proc " & rule.procName & "*(tokens: Tokens): Option[" & rule.nodeName & "]"
        
    text \= ""

    for rule in node.sub :
        text \= "proc " & rule.procName & "*(tokens: Tokens): Option[" & rule.nodeName & "] ="
        text \= makeOpts(rule.ns[1], rule.nodeName).tab & "\n"

    return text
