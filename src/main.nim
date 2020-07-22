import psr/parser
import tables
import sequtils
import strutils

type
    Type = ref object
        base : string
        args : seq[Type]

    Var = object
        kind : Type

    Scope = object
        vars : TableRef[string, Var]

# some usefull logging functions

const
    Err = "\e[31mERROR\e[0m "

proc tab(txt: string) : string = txt.indent(1, "\t")

converter toString*(a: Type): string =
    if a.args.len == 0 :
        return a.base
    else:
        return a.base & "[" & a.args.map(toString).join(", ") & "]"

converter toString*(a: Var): string = a.kind.base

converter toString*(a: ValueNode): string =
    var txt = ""

    txt &= $a.kind
    if a.kind == CallFunc :
        txt &= "\n" & a.fn.toString().tab()
    if a.kind == Variable :
        txt &= ": " & a.name

    return txt

proc fits(a: Type, b: Type): bool =
    # make sure they have the same base type
    if a.base != b.base : return false

    # make sure they have the same number of type args
    if a.args.len != b.args.len : return false

    # make sure they the args work
    for i, arg in a.args :
        if not b.args[i].fits(arg) :
            return false

    return true

proc getVar(value: ValueNode, scope: Scope): Var =
    case value.kind :
    of MakeFunc :
        var kind = Type(base: "fn", args: @[])

        for param in value.params :
            kind.args.add( getVar(param.kind, scope).kind )

        # get the return type of the function
        let ret = getVar(value.ret, scope).kind

        # add the return type to the end of the list of args 
        kind.args.add( ret )

        # get the type that is being returned by the function
        let value = getVar(value.value, scope)

        # if the declared return type and real return type dont match, error
        if not value.kind.fits(ret) :
            echo Err, "real return type does not match declared return type!"

        return Var(kind: kind)
    of CallFunc :
        return Var(kind: getVar(value.fn, scope).kind.args[^1])
    of Variable :
        if scope.vars.hasKey(value.name) :
            return scope.vars[value.name]
        return Var(kind: Type(base: "fault"))
    of StrValue :
        return Var(kind: Type(base: "i32"))
    of IntValue :
        return Var(kind: Type(base: "i32"))

let ast = parse( open("test.txt", fmRead).readAll() )

var baseScope = newTable[string, Var]()

let i32* = Type(base: "i32")
let f32* = Type(base: "f32")
let f64* = Type(base: "f64")

baseScope.add("int", Var(kind: i32))
baseScope.add("+", Var(kind: Type(base: "func", args: @[i32, i32, i32])))
baseScope.add("1", Var(kind: f64))

# echo getVar(ast, Scope(vars: baseScope))
discard getVar(ast, Scope(vars: baseScope))