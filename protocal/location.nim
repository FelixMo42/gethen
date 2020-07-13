import jsonschema, options, json

type DocumentUri = string

jsonSchema:
    Position:
        line : int
        character : int

    Range:
        start : int
        "end" : int

    Location:
        uri : DocumentUri
        range: Range

    LocationLink:
        originSelectionRange ?: Range
        targetUri : DocumentUri
        targetRange : Range
        targetSelectionRange : Range