import sequtils
import strutils
import ../../gen/stream

const eof = '\x00'

let keywords = @['(', ')', '[', ']',':']
let whitespace = @[' ', '\t', '\r', '\n']
let taken = @[eof, '\'', '"'] & keywords & whitespace

type
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

proc eat(file: FileStream) : Token =
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
        echo "ERROR floats arent suported yet"
        return (IntLit, str)

    return (Name, str)

proc tokenize*(file: string): seq[Token] =
    var tokens = newSeq[Token]()

    let stream = FileStream(
        list  : file.toSeq,
        index : 0,
        final : eof
    )

    while true :
        let token = stream.eat()

        if token.kind == EOF :
            break

        if token.kind != Whitespace :
            tokens.add( token )

    return tokens