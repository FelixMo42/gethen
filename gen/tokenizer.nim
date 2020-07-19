import tokens

const eof = '\x00'

let keywords = @['[', ']', '(', ')', ':', '.', '@', '=', '/']
let operation = @['+', '*', '?']
let whitespace = @[' ', '\t', '\r', '\n']
let taken = @[eof, '\'', '"'] & keywords & operation & whitespace

template `:=`[T](a: untyped, b: T): T =
    let a = b
    a

proc next(file: string, index: var int) : char =
    if index == file.len :
        return eof

    let chr = file[index]

    index += 1

    return chr

proc peek(file: string, index: var int) : char =
    if index == file.len :
        return eof

    return file[index]

proc read(file: string, index: var int) : Token =
    let chr = file.next(index)

    if chr == eof :
        return (EOF, "")
    if chr in keywords :
        return (KeyWord, chr & "")
    if chr in operation :
        return (Operator, chr & "")
    if chr == '\'' :
        var str = "\""
        while (c := file.next(index)) != '\'':
            str = str & c
        return (StrLit, str & "\"")

    if chr in whitespace:
        return (Whitespace, "")
    
    var str = chr & ""
    while not (file.peek(index) in taken):
        str = str & file.next(index)

    return (Ident, str)

proc tokenize*(file: string): seq[Token] =
    var index = 0
    var tokens = newSeq[Token]()

    # var max = 100

    while true :
        let token = read(file, index)

        if token.kind == EOF :
            break

        if token.kind != Whitespace :
            tokens.add( token )

    return tokens