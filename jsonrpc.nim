import jsonschema
import json
import options
import streams
import jsonstream
import loging

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

type
    OnNotification = proc (message: NotificationMessage)

    OnRequest = proc (message: RequestMessage): JsonNode

    OnResponse = proc (n: ResponseMessage)

    Jsonrpc = ref object
        onRequest: OnRequest
        onNotification: OnNotification
        ins, outs : FileStream
        currentId : int

# proc request(meth: string, params: JsonNode) =
#         outs.sendJson(%* {
#             "method" : meth,
#             "params" : params
#         })

# proc request(meth: string, params: JsonNode, onResponse: OnResponse) =
#     currentId += 1 

#     outs.sendJson(%* {
#         "id" : currentId,
#         "method" : meth,
#         "params" : params
#     })

proc runJsonrpc*(rpc: Jsonrpc) =
    log "jsonrpc opened"

    while true:
        try:
            let message = rpc.ins.readJson()

            if message.isValid( RequestMessage ):
                let result = rpc.onRequest( RequestMessage(message) )

                rpc.outs.sendJson(%* { "jsonrpc" : "2.0", "id" : message["id"], "result" : result })

            if message.isValid( NotificationMessage ):
                rpc.onNotification( NotificationMessage(message) )

            if message.isValid(ResponseMessage):
                log INFO, "got repsonse to " & message["id"].getStr()
            
        except CatchableError:
            log ERROR, getCurrentExceptionMsg()
        except:
            log ERROR, getCurrentExceptionMsg()
            break

    log "jsonrpc closed"

proc newJsonrpc*(onRequest: OnRequest, onNotification: OnNotification) : Jsonrpc =
    let rpc = Jsonrpc(
        ins: newFileStream(stdin),
        outs: newFileStream(stdout),
        onRequest: onRequest,
        onNotification: onNotification,
        currentId: 0
    )

    runJsonrpc(rpc)

    return rpc