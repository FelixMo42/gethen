import options
import stream

type
    
    AtomNode* = object
        case kind* : AtomKind
        of kind0 :
        of kind1 :
        of kind2 :
    
    StepNodeName* = 
    
    StepNode* = object
        name* : Option[StepNodeName]
        step* : AtomNode
        op* : Option[string]
    
    OptsNodeSteps* = 
    
    OptsNode* = object
        steps* : seq[StepNode]
        steps* : seq[OptsNodeSteps]
    
    RuleNode* = object
        name* : string
        opts* : OptsNode
    
    FileNode* = object
        rules* : seq[RuleNode]

proc atomRule(tokens: Tokens): Option[AtomNode]
proc stepRule(tokens: Tokens): Option[StepNode]
proc optsRule(tokens: Tokens): Option[OptsNode]
proc ruleRule(tokens: Tokens): Option[RuleNode]
proc fileRule(tokens: Tokens): Option[FileNode]

proc atomRule(tokens: Tokens): Option[AtomNode] =
    var save = 0
    if a := tokens.next(IdentRule) :
        return some(AtomNode(
            kind : a
        ))
    if a := tokens.next(StrLitRule) :
        return some(AtomNode(
            body : a
        ))
    save = tokens.save()
    if a := tokens.next("("Rule) :
        if b := tokens.next(optsRule) :
            if c := tokens.next(")"Rule) :
                return some(AtomNode(
                    opts : b
                ))
    tokens.load(save)
    return none(AtomNode)

proc stepRule(tokens: Tokens): Option[StepNode] =
    proc tmp() : Option[TODO]
        if a := tokens.next(IdentRule) :
            if b := tokens.next(":"Rule) :
                return some(TODO(
                ))
        return none(TODO)
    let a = tokens.next(tmp)
    if b := tokens.next(atomRule) :
        let c = tokens.next(OPRule)
        return some(StepNode(
            name : a
            step : b
            op : c
        ))
    return none(StepNode)

proc optsRule(tokens: Tokens): Option[OptsNode] =
    if a := tokens.mult(stepRule) :
        proc tmp() : Option[TODO]
            if a := tokens.next("/"Rule) :
                if b := tokens.mult(stepRule) :
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
    if a := tokens.next("@"Rule) :
        if b := tokens.next(IdentRule) :
            if c := tokens.next("="Rule) :
                if d := tokens.next(optsRule) :
                    return some(RuleNode(
                        name : b
                        opts : d
                    ))
    return none(RuleNode)

proc fileRule(tokens: Tokens): Option[FileNode] =
    let a = tokens.loop(ruleRule)
    if b := tokens.next(EOFRule) :
        return some(FileNode(
            rules : a
        ))
    return none(FileNode)

proc parse*(tokens: seq[Token]): FileNode = 
    return fileRule(Tokens(tokens: tokens, index: 0)).get