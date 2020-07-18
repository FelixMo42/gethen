import strutils
import strformat
import options
import rules

proc cap(text: string) : string = text[0].toUpperAscii() & text[1..^1]
proc tab(text: string) : string = text.indent(1, "    ")

proc `\`(a, b: string): string = a & "\n" & b

template `\=`(a, b: string) = (a = a \ b)

iterator reverse[T](arr: seq[T]): T =
    var i = arr.len - 1
    while i > -1 :
        yield arr[i]
        dec(i)

proc makeStep(step: StepNode, name: char, next: string): string =
    var pattname = ""

    case step.pattern.kind :
    of NAME , BODY :
        pattname = step.pattern.data
    of OPTS :
        pattname = "tmp"

    if step.operator == " " : return
        &"if {name} := tokens.next({pattname}) :" \
            next.tab

    if step.operator == "+" : return
        &"if {name} := tokens.mult({pattname}) :" \
            next.tab

    if step.operator == "*" : return
        &"let {name} = tokens.loop({pattname})" \
        next

    if step.operator == "?" : return
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

proc makeType(step: StepNode): string = 
    case step.pattern.kind :
    of NAME, BODY:
        return "string"
    of OPTS:
        return "()"

proc typeWrap(text: string, operator: string): string = 
    if operator == "*" : return "seq[" & text & "]"
    if operator == "+" : return "seq[" & text & "]"
    if operator == "?" : return "Option[" & text & "]"
    if operator == " " : return text

proc makeRuleType(rule: RuleNode): string = 
    var text = "object"

    for opt in rule.opts:
        for step in opt:
            if step.name.isSome :
                text \= (step.name.get & " : " & makeType(step).typeWrap(step.operator)).tab

    return text

proc make*(file: FileNode): string =
    var text =
        "import options" \
        "import tokens" \ ""

    text \= "type"
    for rule in file.rules :
        text \= (rule.name.cap & "Node = " & makeRuleType(rule) ).tab
        text \= ""

    for rule in file.rules :
        text \= &"proc {rule.name}Rule(tokens: Tokens): Option[{rule.name.cap}Node]"
        
    text \= ""

    for rule in file.rules :
        text \= &"proc {rule.name}Rule(tokens: Tokens): Option[{rule.name.cap}Node] ="
        text \= makeOpts(rule.opts, rule.name.cap & "Node").tab & "\n"

    return text