import sequtils
import strutils
import ../../gen/stream
# import ../report

const eof = '\x00'

let keywords = @['(', ')', '[', ']',':']
let whitespace = @[' ', '\t', '\r', '\n']
let taken = @[eof, '\'', '"'] & keywords & whitespace

type
    Pos* = (int, int)
    Spot* = (Pos, Pos)

    TokenKind* = enum
        Name
        KeyWord
        Whitespace
        
        StrLit
        IntLit

        EOF

    Token* = tuple
        kind : TokenKind
        body : string
        spot : Spot

    Tokens* = Inputs[Token]

    FileStream = Inputs[char]

proc isInt(txt: string): bool =
    for c in txt:
        if not c.isDigit() :
            return false
    return true

proc isFloat(txt: string): bool =
    var hasDot = false
    for c in txt:
        if c == '.' :
            if hasDot :
                return false
            else :
                hasDot = true 
        elif not c.isDigit() :
            return false

    return true

proc eat(file: FileStream) : (TokenKind, string) =
    let chr = file.read()

    # reached end of file
    if chr == eof : return (EOF, "")

    # this is specal punctuation
    if chr in keywords : return (KeyWord, chr & "")

    # start of a string
    if chr == '\'' :
        var str = "\""
        while file.peek() != '\'' :
            str = str & file.read()
        file.skip()
        return (StrLit, str & "\"")

    # just some boring whitespace
    if chr in whitespace : return (Whitespace, "")
    
    var str = chr & ""
    while not (file.peek() in taken):
        str = str & file.read()

    if isInt(str) :
        return (IntLit, str)

    if isFloat(str) :
        # warn "floats arent suported yet"
        return (IntLit, str)

    return (Name, str)

proc tokenize*(file: string): seq[Token] =
    var tokens = newSeq[Token]()
    let lines = file.split("\n")

    for i, line in lines: 
        let stream = FileStream(
            list  : line.toSeq,
            index : 0,
            final : eof
        )

        while true :
            # get the start of the token
            let start = stream.index

            # read the next token on the line
            let (kind, body) = stream.eat()

            # get the end of the token
            let stop = stream.index

            # weve reached the end of the line, lets stop
            if kind == EOF : break

            # if its whitepace then we can move on
            if kind == Whitespace : continue

            # the spot in the file with the token
            let spot = ((i, start), (i, stop))

            # add the token to are list of tokens
            tokens.add( (kind, body, spot) )

    return tokens