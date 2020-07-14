import jsonschema
import json
import options

template onValid*(data, kind, body) =
    if data.isValid(kind):
        # var data = kind(data)
        body

template onRequest*(data, body) = onValid(data, RequestMessage, body)

template onResponse*(data, body) = onValid(data, ResponseMessage, body)

template onNotification*(data, body) = onValid(data, NotificationMessage, body)

jsonSchema:
    Message:
        "jsonrpc" : string

    RequestMessage extends Message:
        "id" : int or string
        "method" : string
        "params" ?: any

    ResponseMessage extends Message:
        "id" : int or string or nil
        "result" ?: any
        "error" ?: ResponseError

    ResponseError:
        "code" : int
        "message" : string
        "data" ?: any

    NotificationMessage extends Message:
        "method" : string
        "params" : any

    CancelParams:
        "id" : int or string

    ProgressParams:
        "token" : string or int
        "value" : any