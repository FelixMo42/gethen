import jsonschema

# not implemented : Progress Support

# \n``` -> ~
# typescript\n([^~]*)~[^~]*~

# ```\n[^%]*
# /\*\*\n[^/]*/

type
    Id = int or string
    DocumentUri = string

jsonSchema:
    # json rpc protocol

    Message:
        jsonrpc : string

    RequestMessage extends Message:
        id : Id
        "method" : string
        params ?: any[] or any

    ResponseMessage extends Message:
        id : Id
        result ?: any
        error ?: ResponseError

    ResponseError:
        code : int
        message : string
        data ?: any

    NotificationMessage extends Message:
        "method": string

        params ?: any[] or any

    CancelParams:
        id : Id
    
    # lsp protocol

    Position:
        line: int
        character : int

    Range:
        start: Position
        end: Position

    Location:
        uri: DocumentUri
        range: Range

    LocationLink:
        originSelectionRange?: Range
        targetUri: DocumentUri
        targetRange: Range
        targetSelectionRange: Range

    Diagnostic:
        range: Range
        severity?: DiagnosticSeverity
        code?: number | string