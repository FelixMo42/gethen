import tokenizer
import ../psr/rules
import ../psr/build

let ast = parse( tokenize( open("main.txt", fmRead).readAll() ) )

open("out.nim", fmWrite).write( make(ast) )