import options
import tokens

type
    
    AtomNode = object
        case kind : AtomKind
        of c1 :
        of c1 :
        of c1 :

    
    StepNodeName = 
    
    StepNode = object
        name : Option[StepNodeName]
        step : AtomNode
        op : Option[string]

    
    OptsNodeSteps = 
    
    OptsNode = object
        steps : seq[StepNode]
        steps : seq[OptsNodeSteps]

    
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
    if a := tokens.next(Ident) :
        return some(AtomNode(
            kind : a
        ))
    if a := tokens.next(StrLit) :
        return some(AtomNode(
            body : a
        ))
    save = tokens.save()
    if a := tokens.next("(") :
        if b := tokens.next(opts) :
            if c := tokens.next(")") :
                return some(AtomNode(
                    opts : b
                ))
    tokens.load(save)
    return none(AtomNode)

proc stepRule(tokens: Tokens): Option[StepNode] =
    proc tmp() : Option[TODO]
        if a := tokens.next(Ident) :
            if b := tokens.next(":") :
                return some(TODO(
                ))
        return none(TODO)
    let a = tokens.next(tmp)
    if b := tokens.next(atom) :
        let c = tokens.next(OP)
        return some(StepNode(
            name : a
            step : b
            op : c
        ))
    return none(StepNode)

proc optsRule(tokens: Tokens): Option[OptsNode] =
    if a := tokens.mult(step) :
        proc tmp() : Option[TODO]
            if a := tokens.next("/") :
                if b := tokens.mult(step) :
                    return some(TODO(
                    ))
            return none(TODO)
        let b = tokens.loop(tmp)
        return some(OptsNode(
            steps : a
            steps : b
        ))
    return none(OptsNode)

proc ruleRule(tokens: Tokens): Option[RuleNode] =
    if a := tokens.next("@") :
        if b := tokens.next(Ident) :
            if c := tokens.next("=") :
                if d := tokens.next(opts) :
                    return some(RuleNode(
                        name : b
                        opts : d
                    ))
    return none(RuleNode)

proc fileRule(tokens: Tokens): Option[FileNode] =
    let a = tokens.loop(rule)
    if b := tokens.next(EOF) :
        return some(FileNode(
            rules : a
        ))
    return none(FileNode)
