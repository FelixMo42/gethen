type
    Position* = tuple
        line : int
        colm : int

proc compare*(a, b: Position) : int =
    if a.line > b.line : return  1
    if a.line < b.line : return -1
    return a.colm - b.colm

proc `>=`*(a, b: Position) : bool = compare(a, b) >= 0
proc `<=`*(a, b: Position) : bool = compare(a, b) <= 0

proc `+`*(position: Position, length: int) : Position =
    return (position.line, position.colm + length)

let node = ast.get(target)

node.complete()

