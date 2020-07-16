type
    Rule = seq[Case]

    Case = ref object
        step : Step

    StepKind = enum
        OnePlus,
        ZeroPlus,
        Optional,

        # predicates
        AndPredicate,
        NotPredicate,

        # 
        Seqence,
        Choices,

        # base rules
        TokenKind,
        TokenBody,
        TokenRule

    Step = object
        case kind: StepKind

        of OnePlus, ZeroPlus, Optional, AndPredicate, NotPredicate, Seqence, Choices :
            steps : seq[Step]

        else:
            discard

func sequence(): string =
    ""