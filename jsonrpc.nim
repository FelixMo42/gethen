import json
import options
import streams
import jsonstream
import loging

type
    NotificationMessage* = object
        action* : string
        params* : JsonNode

    RequestMessage* = object 
        id : JsonNode
        action* : string
        params* : JsonNode

    ResponseMessage* = object
        id : JsonNode
        result : JsonNode
        error  : JsonNode

    # jsonrpc callbacks
    OnNotification = proc (m: NotificationMessage, rpc: Jsonrpc)
    OnRequest = proc (m: RequestMessage, rpc: Jsonrpc): JsonNode
    OnResponse = proc (m: ResponseMessage, rpc: Jsonrpc)

    # the man himself
    Jsonrpc* = ref object
        onRequest: OnRequest
        onNotification: OnNotification
        ins, outs : FileStream
        currentId : int

proc getNewId*(rpc: Jsonrpc): int =
    rpc.currentId += 1
    return rpc.currentId

proc notify*(rpc: Jsonrpc, action: string, params: JsonNode) =
    rpc.outs.sendJson(%* {
        "jsonrpc" : "2.0",
        "method" : action,
        "params" : params
    })

proc request*(rpc: Jsonrpc, action: string, params: JsonNode, onResponse: OnResponse) =
    rpc.outs.sendJson(%* {
        "jsonrpc" : "2.0",
        "id" : rpc.getNewId(),
        "method" : action,
        "params" : params
    })

# type vaildation

proc hasKey(json: JsonNode, key: string, kind: JsonNodeKind): bool =
    json.hasKey(key) and json[key].kind == kind

template isRequestMessage(message: JsonNode): bool =
    message.hasKey("id") and message.hasKey("method", JString) and message.hasKey("params")

template isNotificationMessage(message: JsonNode): bool =
    message.hasKey("method", JString) and message.hasKey("params")

template isResponseMessage(message: JsonNode): bool =
    message.hasKey("id") and message.hasKey("params")

template toRequestMessage(message: JsonNode): RequestMessage =
    RequestMessage(id: message["id"], action: message["method"].getStr(), params: message["params"])

template toNotificationMessage(message: JsonNode): NotificationMessage =
    NotificationMessage(action: message["method"].getStr(), params: message["params"])

template toResponseMessage(message: JsonNode): ResponseMessage =
    ResponseMessage(id: message["id"], result: message["result"])

# the main event

proc runJsonrpc*(rpc: Jsonrpc) =
    log "jsonrpc opened"

    while true:
        try:
            let message = rpc.ins.readJson()

            # log DEBUG, message

            if isRequestMessage(message):
                let result = rpc.onRequest( toRequestMessage(message), rpc )

                rpc.outs.sendJson(%* { "jsonrpc" : "2.0", "id" : message["id"], "result" : result })

            elif isNotificationMessage(message):
                rpc.onNotification( toNotificationMessage(message) , rpc )

            elif isResponseMessage(message):
                log INFO, "got repsonse to request " & $message["id"].getInt()

            else:
                log ERROR, "unknow message type " & $message
            
        except CatchableError:
            log ERROR, getCurrentException().name, getCurrentException().msg 
        except:
            log ERROR, getCurrentException().name, getCurrentException().msg
            break

    log "jsonrpc closed"

proc newJsonrpc*(onRequest: OnRequest, onNotification: OnNotification) : Jsonrpc =
    return Jsonrpc(
        ins: newFileStream(stdin),
        outs: newFileStream(stdout),
        onRequest: onRequest,
        onNotification: onNotification,
        currentId: 0
    )

proc jsonrpc*(onRequest: OnRequest, onNotification: OnNotification) = 
    runJsonrpc(newJsonrpc(onRequest, onNotification))