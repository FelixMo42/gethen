type
    Node = object of RootObj
        kind : int
    
    Token = object of Node
        body : string

proc test(node: Node) =
    if node of Token :
        echo "123"
    else:
        echo "456"


test( Token(kind: 2, body: "123") )