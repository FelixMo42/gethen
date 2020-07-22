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

    Scope = ref object
        vars : TableRef[string, Var]
        prev : Scope

# some basic value types

let i32* = Type(base: "i32")
let f32* = Type(base: "f32")
let f64* = Type(base: "f64")
let str* = Type(base: "str")

# some usefull logging functions

const
    Err = "\e[31mERROR\e[0m "

proc tab(txt: string) : string = txt.indent(1, "   ")

converter toString*(a: Type): string =
    if a.args.len == 0 :
        return a.base
    else:
        return a.base & "[" & a.args.map(toString).join(", ") & "]"

converter toString*(a: Var): string = a.kind.base

converter toString*(a: ValueNode): string =
    var txt = "~" & $a.kind

    if a.kind == CallFunc :
        txt &= "\n" & (a.fn.toString()).tab()

        txt &= "\n" & " args: "
        for arg in a.args :
            txt &= "\n" & arg.toString().tab()

    if a.kind == Variable :
        txt &= ": " & a.name
    if a.kind == MakeFunc :
        txt &= " : "
        for param in a.params :
            txt &= param.name & "(" & param.kind.toString() & ")" & " "
        txt &= "-> " & a.ret.toString()
        txt &= "\n"  & a.value.toString().tab()

    return txt

#

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

proc get(scope: Scope, name: string): Var =
    if scope.vars.hasKey(name) :
        return scope.vars[name]

    if scope.prev != nil :
        return scope.prev.get(name)

    echo Err, "undefined variable"

    return Var(kind: Type(base: "fault"))

proc getVar(value: ValueNode, scope: Scope): Var =
    case value.kind :
    of MakeFunc :
        var kind = Type(base: "fn", args: @[])

        let funcScope = Scope(
            vars: newTable[string, Var](),
            prev: scope
        )

        for param in value.params :
            # get the type of the paramater
            let paramKind = getVar(param.kind, scope).kind

            # add it to the type specification of the functions
            kind.args.add( getVar(param.kind, scope).kind )

            # add the paramater to the scope
            funcScope.vars[param.name] = Var(kind: paramKind)

        # get the return type of the function
        let ret = getVar(value.ret, scope).kind

        # add the return type to the end of the list of args 
        kind.args.add( ret )

        # get the type that is being returned by the function
        let value = getVar(value.value, funcScope)

        # if the declared return type and real return type dont match, error
        if not value.kind.fits(ret) :
            echo Err, "real return type does not match declared return type!"

        return Var(kind: kind)
    of CallFunc :
        # get the function were calling
        let fn = getVar(value.fn, scope)

        # get the expected paramaters of the functions
        let params = fn.kind.args[0..^2]

        # check if they have the same number of arguments
        if value.args.len != params.len :
            echo Err, "unexpected number of arguments"

        for i in 0..<min(value.args.len, params.len):
            if not getVar(value.args[i], scope).kind.fits( params[i] ) :
                echo Err, "wrong paramater tye"

        return Var(kind: fn.kind.args[^1])
    of Variable :
        return scope.get(value.name)
    of StrValue :
        return Var(kind: Type(base: "i32"))
    of IntValue :
        return Var(kind: Type(base: "i32"))

let ast = parse( open("test.txt", fmRead).readAll() )

var baseScope = newTable[string, Var]()

baseScope.add("int", Var(kind: i32))
baseScope.add("+"  , Var(kind: Type(base: "func", args: @[i32, i32, i32])))
baseScope.add("1"  , Var(kind: i32))

# echo ast

# echo getVar(ast, Scope(vars: baseScope))
# discard getVar(ast, Scope(vars: baseScope))

# import wrp/tojs
import wrp/topy

echo toPy(ast)
