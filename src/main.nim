import psr/parser
import tables

type
    Var = object
        kind : int

    Scope = object
        vars : Table[string, Var]

proc run(ast: ValueNode) =
    case ast.kind :
    of MakeFunc :
        discard
    of CallFunc :
        discard
    of Variable :
        discard

let ast = parse( open("test.txt", fmRead).readAll() )

run(ast)