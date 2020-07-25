import validate

let errs = validate( open("test.gth", fmRead).readAll() )

echo "found ", errs.len, " errors"

for err in errs :
    echo err

# const target = "py"

# when target == "py" :
#     import wrp.topy
#     echo toPy(ast)

# when target == "js" :
#     import wrp.tojs
#     echo toJs(ast)