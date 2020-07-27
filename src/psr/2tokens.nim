import sequtils
import strutils
import streams

# import src/report

import src/position
import src/symbol

const eof = '\x00'

let keywords = @['(', ')', '[', ']',':']
let taken = @['\x00', '\'', '"'] & keywords & whitespace

type Spot* = (Position, Position)

proc eat(file: StringStream) : (TokenKind, string) =
    if file.peekChar() in keywords : return (KeyWord, file.readStr(1))

    if file.peekChar() == '\"' :
        let len = 1

        while file.peekChar() != '\"' : len += 1
        
        return (StrLit, file.readStr(len))

    let len = 1

    while not (file.peekChar() in taken): len += 1

    let text = file.readStr(len)
    
    if text[0].isDigit() : return (NumLit, str)

    return (Variable, str)

proc nextChar(stream: StringStream) =
    discard stream.readChar()

proc tokenize*(file: string): seq[Token] =
    var tokens = newSeq[Symbol]()
    let stream = newStringStream(line.toSeq)

    let line = 0
    let colm = 0

    while true :
        if steam.peekChar() == "\n" :
            line += 1
            colm  = 0

            steam.nextChar()

        while steam.peekChar() in [" ", "\t"] :
            colm += 1

            steam.nextChar()

        # we've reached the end of the file, lets stop
        if stream.atEnd() : break

        # get the spot at the start of the token
        let spot = (line, colm)

        # read the next token on the line
        let (kind, text) = stream.eat()

        colm += text.len

        # add the token to are list of tokens
        tokens.add( newSymbol(
            spot : spot,
            text : text,
            kind : kind
        ) )

    return tokens