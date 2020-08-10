import position

type
    SymbolKind* = enum
        KeyWord
        Variable
        
        StringLit
        NumberLit
        BooleanLit
        
    Symbol = object
        text : string
        spot : Position
        kind : SymbolKind
        scope : Scope

    Scope = ref object
        range : (Position, Position)
        symbols : seq[Symbol]

    NodeKind = enum a, b

    Node = ref object
        kind : NodeKind
        text : string
        children : seq[Node]
        scope : Node
        blame : Position

# hygienic

proc `in`(position: Position, scope: Scope) : bool =
    return
        position >= scope.range[0] and
        position <= scope.range[1]

proc `in`(position: Position, symbol: Symbol) : bool =
    return position in symbol.scope

proc get*(scope: Scope, target: Position): Symbol

proc get*(symbol: Symbol, target: Position): Symbol =
    let symbolIncludesTarget =
        target >= symbol.spot and
        target <= symbol.spot + symbol.text.len

    if symbolIncludesTarget : return symbol

    else : return symbol.scope.get(target)

proc get*(scope: Scope, target: Position): Symbol =
    for symbol in scope.symbols :
        if target in symbol :
            return symbol.get(target)

proc newScope(a, b: Position): Scope =
    return Scope(
        range : (a, b),
        symbols : @[]
    )

proc newSymbol(spot: Position, text: string, kind: SymbolKind): Symbol =
    return Symbol(
        spot : spot,
        text : text,
        kind : kind
    )