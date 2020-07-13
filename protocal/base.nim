import jsonschema, options, json

jsonSchema:
    # base protocal

    Message:
        jsonrpc : string

    RequestMessage extends Message:
        id : string or int
        "method" : string
        params ?: any or any[]

    ResponseMessage extends Message:
        id : string or int or nil
        "result" ?: any
        error ?: ResponseError

    ResponseError:
        code : int
        message : string
        data ?: any

    NotificationMessage extends Message:
        "method" : string
        params ?: any