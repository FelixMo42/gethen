import base

const src* = @[
    (KeyWord, "@"),
    (Ident, "atom"),
    (KeyWord, "="),
        (Ident, "NAME"),
        (KeyWord, "/"),
        (Ident, "STRING"),
        (KeyWord, "/"),
        (StrLit, "\"(\""),
        (Ident, "opts"),
        (StrLit, "\")\""),

    (KeyWord, "@"),
    (Ident, "step"),
    (KeyWord, "="),
        (Ident, "name"),
        (KeyWord, ":"),
        (KeyWord, "("),
            (Ident, "NAME"),
            (StrLit, "\":\""),
        (KeyWord, ")"),
        (Operator, "?"),

        (Ident, "pattern"),
        (KeyWord, ":"),
        (Ident, "atom"),

        (Ident, "operator"),
        (KeyWord, ":"),
        (Ident, "OPERATOR"),
        (Operator, "?"),

    (KeyWord, "@"),
    (Ident, "opts"),
    (KeyWord, "="),
        (Ident, "steps"),
        (KeyWord, ":"),
        (Ident, "step"),
        (Operator, "+"),

        (Ident, "steps"),
        (KeyWord, ":"),
        (KeyWord, "("),
            (StrLit, "\"/\""),
            (Ident, "step"),
            (Operator, "+"),
        (KeyWord, ")"),
        (Operator, "*"),

    (KeyWord, "@"),
    (Ident, "rule"),
    (KeyWord, "="),
        (StrLit, "\"@\""),

        (Ident, "name"),
        (KeyWord, ":"),
        (Ident, "NAME"),

        (StrLit, "\"=\""),

        (Ident, "opts"),
        (KeyWord, ":"),
        (Ident, "opts"),

    (KeyWord, "@"),
    (Ident, "file"),
    (KeyWord, "="),
        (Ident, "rules"),
        (KeyWord, ":"),
        (Ident, "rule"),
        (Operator, "*"),

        (Ident, "EOF")
]