import strutils
import position
import src/symbol2
import streams

const eof = '\x00'

const keywords = @['(', ')', '[', ']',':']
const whitespace = @[' ', '\t']
const newlines = @['\r','\n']
const taken = @[eof, '\'', '"'] & keywords & whitespace & newlines

proc skipChar(stream: StringStream) =
    discard stream.readChar()

proc readUntil(file: StringStream, puncuation: seq[char]) : int =
    var length = 0

    let start = file.getPosition()

    while file.peekChar() notin puncuation and not file.atEnd() :
        file.skipChar()
        length += 1

    file.setPosition(start)

    return length
    
proc eat(file: StringStream) : (SymbolKind, string) =
    if file.peekChar() in keywords : return (KeyWord, file.readStr(1))

    if file.peekChar() == '\"' :
        var stringLength = 1 + file.readUntil(@[ '\"' ]) + 1
        
        return (StringLit, file.readStr(stringLength))

    var len = file.readUntil(taken)

    var text = file.readStr(len)

    if text[0].isDigit() : return (NumberLit, text)

    return (Variable, text)

proc tokenize*(file: string): seq[Symbol] =
    var tokens = newSeq[Symbol]()
    let stream = newStringStream(file)

    var position = newPosition()

    while true :
        # if were at a new line skip it and set are position
        if stream.peekChar() in newlines :
            position = position.nextLine()
            stream.skipChar()
            continue

        # skip over whitespace
        if stream.peekChar() in whitespace :
            position = position.nextChar()
            stream.skipChar()
            continue

        # we've reached the end of the file, lets stop
        if stream.atEnd() : break

        # read the next token on the line
        let (kind, text) = stream.eat()

        # add the token to are list of tokens
        tokens.add( newSymbol(kind, text, position) )

        # skip over the contents of symbol
        position = position + text.len

    return tokens