type Position* = tuple
    line : int
    colm : int

proc newPosition*(a, b: int = 0): Position =
    return (a, b)

proc compare*(a, b: Position) : int =
    if a.line > b.line : return  1
    if a.line < b.line : return -1
    return a.colm - b.colm

proc `>=`*(a, b: Position) : bool = compare(a, b) >= 0
proc `<=`*(a, b: Position) : bool = compare(a, b) <= 0

proc `+`*(position: Position, length: int) : Position =
    return (position.line, position.colm + length)

proc nextLine*(a: Position): Position =
    return newPosition(a.line + 1, 0)

proc nextChar*(a: Position): Position =
    return newPosition(a.line, a.colm + 1)