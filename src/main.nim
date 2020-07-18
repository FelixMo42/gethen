import source
import rules
import tokens
import options
import build

let ast = parse( Tokens( tokens : src, index  : 0 ) ).get

open("out.nim", fmWrite).write( make(ast) )