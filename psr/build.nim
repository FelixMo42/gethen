import strutils
import strformat
import sequtils
import options
import rules

proc makeOpts(opts: OptsNode, rule: string): string

proc cap(text: string) : string = text[0].toUpperAscii() & text[1..^1]
proc tab(text: string) : string = text.indent(1, "    ")

proc notEmpty(text: string) : bool = text != ""

template `\`(a, b: string): string = a & "\n" & b
template `\=`(a, b: string) = (a = a \ b)

iterator reverse[T](arr: seq[T]): T =
    var i = arr.len - 1
    while i > -1 :
        yield arr[i]
        dec(i)

proc hasRule(file: FileNode, rule: string): bool =
    for r in file.rules :
        if r.name == rule :
            return true
    return false

proc makeStep(step: StepNode, name: char, next: string): string =
    var pattname = ""
    var text = ""

    case step.pattern.kind :
    of NAME , BODY :
        pattname = step.pattern.data
    of OPTS :
        text = 
            "proc tmp() : Option[]" \
                makeOpts(step.pattern.opts, "tmp").tab \ ""

        pattname = "tmp"

    if step.operator == " " : return text &
        &"if {name} := tokens.next({pattname}) :" \
            next.tab

    if step.operator == "+" : return text &
        &"if {name} := tokens.mult({pattname}) :" \
            next.tab

    if step.operator == "*" : return text &
        &"let {name} = tokens.loop({pattname})" \
        next

    if step.operator == "?" : return text &
        &"let {name} = tokens.next({pattname})" \
        next

proc makeOpt(opt: seq[StepNode], rule: string): string =
    var text = &"return some({rule}())"
    var name = 'a'

    for step in opt.reverse:
        text = makeStep(step, name, text)
        inc(name)

    return text

proc makeOpts(opts: OptsNode, rule: string): string =
    if opts.len == 1 :
        return makeOpt(opts[0], rule) \ &"return none({rule.cap})"

    var text = "var save = 0"

    for opt in opts:
        if opt.len == 1:
            text \= makeOpt(opt, rule)
        else:
            text \= "save = tokens.save()"
            text \= makeOpt(opt, rule)
            text \= "tokens.load(save)"

    return text \ &"return none({rule.cap})"

proc makeType(step: StepNode, rule: RuleNode, file: FileNode): string = 
    case step.pattern.kind :
    of NAME:
        if file.hasRule(step.pattern.data):
            return step.pattern.data.cap & "Node"
        else:
            return "string"
    of BODY:
        return "string"
    of OPTS:
        return rule.name.cap & "Node" & step.name.get.cap

proc typeWrap(text: string, operator: string): string = 
    if operator == "*" : return "seq[" & text & "]"
    if operator == "+" : return "seq[" & text & "]"
    if operator == "?" : return "Option[" & text & "]"
    if operator == " " : return text

proc makeTupleTape(step: StepNode): string =
    return ""

proc makeTuple(opts: OptsNode, name: string): string =
    let tupl = opts[0].map(makeTupleTape).filter(notEmpty).join(",")
    return name & " = " & tupl

proc makeRuleType(rule: RuleNode, file: FileNode): string = 
    var text = ""

    for i, opt in rule.opts :
        for j, step in opt :
            if step.name.isSome and step.pattern.kind == OPTS :
                text \= makeTuple(step.pattern.opts, &"{rule.name.cap}Node{step.name.get.cap}")
                text \= ""

    text \= rule.name.cap & "Node = object"

    if rule.opts.len == 1 :
        for step in rule.opts[0] :
            if step.name.isSome :
                text \= (step.name.get & " : " & makeType(step, rule, file).typeWrap(step.operator)).tab
    else :
        text \= "case kind : " & rule.name.cap & "Kind"

        for opt in rule.opts :
            text \= "of c1 :"

    return text

proc make*(file: FileNode): string =
    var text =
        "import options" \
        "import tokens" \ ""

    text \= "type"

    for rule in file.rules :
        text \= makeRuleType(rule, file).tab
        text \= ""

    for rule in file.rules :
        text \= &"proc {rule.name}Rule(tokens: Tokens): Option[{rule.name.cap}Node]"
        
    text \= ""

    for rule in file.rules :
        text \= &"proc {rule.name}Rule(tokens: Tokens): Option[{rule.name.cap}Node] ="
        text \= makeOpts(rule.opts, rule.name.cap & "Node").tab & "\n"

    return text