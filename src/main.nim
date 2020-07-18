import tokenizer
import rules
import tokens
import options
import build

let ast = parse( Tokens(
    tokens : tokenize( open("main.txt", fmRead).readAll() ),
    index  : 0
) ).get

open("out.nim", fmWrite).write( make(ast) )