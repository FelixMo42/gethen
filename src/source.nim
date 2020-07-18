import tokens



let src* = @[
    (KeyWord, "@"),
    (Ident, "atom"),
    (KeyWord, "="),
        (Ident, "Ident"),
        (KeyWord, "/"),
        (Ident, "StrLit"),
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
            (Ident, "Ident"),
            (StrLit, "\":\""),
        (KeyWord, ")"),
        (Operator, "?"),

        (Ident, "pattern"),
        (KeyWord, ":"),
        (Ident, "atom"),

        (Ident, "operator"),
        (KeyWord, ":"),
        (Ident, "Operator"),
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
        (Ident, "Ident"),

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