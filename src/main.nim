import psr/parser
import tables

type
    Type = ref object
        base : string
        args : seq[Type]

    Var = object
        kind : Type

    Scope = object
        vars : TableRef[string, Var]

converter toString*(a: Type): string = a.base
converter toString*(a: Var): string = a.kind.base

proc getVal(value: ValueNode, scope: Scope): Var =
    case value.kind :
    of MakeFunc :
        var kind = Type(base: "func", args: @[])

        for param in value.params :
            kind.args.add( getVal(param.kind, scope).kind )

        kind.args.add( getVal(value.ret, scope).kind )

        return Var(kind: kind)
    of CallFunc :
        return Var(kind: getVal(value.fn, scope).kind.args[^1])
    of Variable :
        if scope.vars.hasKey(value.name) :
            return scope.vars[value.name]
        return Var(kind: Type(base: "not a var"))
    of StrValue :
        return Var(kind: Type(base: "i32"))
    of IntValue :
        return Var(kind: Type(base: "i32"))

let ast = parse( open("test.txt", fmRead).readAll() )

var baseScope = newTable[string, Var]()

baseScope.add("int", Var(kind: Type(base: "i32")))

echo getVal(ast, Scope(vars: baseScope))

