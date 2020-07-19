import tokenizer
import rules
import build

let ast = parse( tokenize( open("main.txt", fmRead).readAll() ) )

open("out.nim", fmWrite).write( make(ast) )