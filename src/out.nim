import options
import tokens

type
    
    AtomNode = object

    
    name_0_0 = ()
    
    StepNode = object
        name : Option[()]
        step : AtomNode
        op : Option[string]

    
    OptsNode = object

    
    RuleNode = object
        name : string
        opts : OptsNode

    
    FileNode = object
        rules : seq[RuleNode]

proc atomRule(tokens: Tokens): Option[AtomNode]
proc stepRule(tokens: Tokens): Option[StepNode]
proc optsRule(tokens: Tokens): Option[OptsNode]
proc ruleRule(tokens: Tokens): Option[RuleNode]
proc fileRule(tokens: Tokens): Option[FileNode]

proc atomRule(tokens: Tokens): Option[AtomNode] =
    var save = 0
    if a := tokens.next(NAME) :
        return some(AtomNode())
    if a := tokens.next(STRING) :
        return some(AtomNode())
    save = tokens.save()
    if c := tokens.next("(") :
        if b := tokens.next(case) :
            if a := tokens.next(")") :
                return some(AtomNode())
    tokens.load(save)
    return none(AtomNode)

proc stepRule(tokens: Tokens): Option[StepNode] =
    let c = tokens.next(tmp)
    if b := tokens.next(atom) :
        let a = tokens.next(OP)
        return some(StepNode())
    return none(StepNode)

proc optsRule(tokens: Tokens): Option[OptsNode] =
    if b := tokens.mult(step) :
        let a = tokens.loop(tmp)
        return some(OptsNode())
    return none(OptsNode)

proc ruleRule(tokens: Tokens): Option[RuleNode] =
    if d := tokens.next("@") :
        if c := tokens.next(NAME) :
            if b := tokens.next("=") :
                if a := tokens.next(opts) :
                    return some(RuleNode())
    return none(RuleNode)

proc fileRule(tokens: Tokens): Option[FileNode] =
    let b = tokens.loop(rule)
    if a := tokens.next(EOF) :
        return some(FileNode())
    return none(FileNode)
