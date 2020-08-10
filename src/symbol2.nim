import position

type
    SymbolKind* = enum
        KeyWord
        Variable
        
        StringLit
        NumberLit
        BooleanLit
        
    Symbol* = object
        text : string
        area : Area
        kind : SymbolKind
        args : seq[Symbol]

# hygienic

proc `in`*(position: Position, symbol: Symbol) : bool =
    return position in symbol.area

proc get*(symbol: Symbol, target: Position): Symbol =
    if target in symbol :
        for child in symbol.args :
            if target in child :
                return symbol.get(target)
            
        return symbol

proc newSymbol*(kind: SymbolKind, text: string, area: Area): Symbol =
    return Symbol(
        text : text,
        area : area,
        kind : kind
    )