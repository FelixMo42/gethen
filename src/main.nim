import tokenizer
import rules
import tokens
import options
import build

for toks in tokenize( open("main.txt", fmRead).readAll() ) :
    echo toks

let ast = parse( Tokens(
    tokens : tokenize( open("main.txt", fmRead).readAll() ),
    index  : 0
) )
# .get

echo ast

# open("out.nim", fmWrite).write( make(ast) )