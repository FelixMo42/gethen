import tables
# import sequtils
# import strutils
import strformat
import psr/parser
import psr/tokens
import reporter

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

let inheritanceTree = newTable[string, seq[string]]()

proc newType(base: string, parents: seq[string]=newSeq[string]()): Type =
    inheritanceTree[base] = parents

    return Type(base: base)

let i64* = newType("i64")
let i32* = newType("i32")
let i16* = newType("i16")
let f64* = newType("i32")
let f32* = newType("i32")
let str* = newType("str")
let arr* = newType("arr")

#

proc fits(a: Type, b: Type): bool =
    # if either are errors, dont do more errors
    if a.base == "fault" or b.base == "fault" : return true

    # make sure they have the same base type
    if a.base != b.base : return false

    # make sure they have the same number of type args
    if a.args.len != b.args.len : return false

    # make sure they the args work
    for i, arg in a.args :
        if not b.args[i].fits(arg) :
            return false

    return true

proc get(scope: Scope, name: Token): Var =
    if scope.vars.hasKey(name) :
        return scope.vars[name]

    if scope.prev != nil :
        return scope.prev.get(name)

    fail name, &"variable '{name.body}' is not defined"

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
        let output = getVar(value.output, funcScope)

        # if the declared return type and real return type dont match, error
        if not output.kind.fits(ret) :
            fail value.ret, "real return type does not match declared return type!"

        return Var(kind: kind)
    of CallFunc :
        # get the function were calling
        let fn = getVar(value.fn, scope)

        # get the expected paramaters of the functions
        let params = fn.kind.args[0..^2]

        # check if they have the same number of arguments
        if value.args.len != params.len :
            fail value, &"expected {params.len} arguments, got {value.args.len}"

        # make sure the args are all of the right type
        for i in 0..<min(value.args.len, params.len):
            if not getVar(value.args[i], scope).kind.fits( params[i] ) :
                fail value.args[i], "wrong paramater type"

        return Var(kind: fn.kind.args[^1])
    of Variable :
        return scope.get(value.name)
    of StrValue :
        return Var(kind: Type(base: "i32"))
    of IntValue :
        return Var(kind: Type(base: "i32"))

# create the programe scope
var baseScope = newTable[string, Var]()

# add type bindings
baseScope.add("int", Var(kind: i32))

# add math operators
baseScope.add("+" , Var(kind: Type(base: "func", args: @[i32, i32, i32])))
baseScope.add("-" , Var(kind: Type(base: "func", args: @[i32, i32, i32])))
baseScope.add("*" , Var(kind: Type(base: "func", args: @[i32, i32, i32])))
baseScope.add("/" , Var(kind: Type(base: "func", args: @[i32, i32, i32])))
baseScope.add("^" , Var(kind: Type(base: "func", args: @[i32, i32, i32])))

proc validate*(text: string): Report =
    reporter.record()

    # first parse the text
    let ast = parse(text)

    # then validate the ast
    discard getVar(ast, Scope(vars: baseScope))

    let log = reporter.report()

    return log