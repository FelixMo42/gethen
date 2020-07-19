import sequtils
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

proc eat(file: FileStream) : Token =
    let chr = file.read()

    if chr == eof :
        return (EOF, "")
    if chr in keywords :
        return (KeyWord, chr & "")
    if chr == '\'' :
        var str = "\""
        while file.peek() != '\'' :
            str = str & file.read()
        file.skip()
        return (StrLit, str & "\"")

    if chr in whitespace:
        return (Whitespace, "")
    
    var str = chr & ""
    while not (file.peek() in taken):
        str = str & file.read()

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