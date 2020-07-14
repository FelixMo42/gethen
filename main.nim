import streams
import loging
import os
import jsonstream
import strutils
import json
import uri

const name = "omni lsp"
const version = "0.0.0"
const storage = currentSourcePath().parentDir / "tmp"

let ins  = newFileStream(stdin)
let outs = newFileStream(stdout)


# make sure that a tmp folder exist
discard existsOrCreateDir(storage)

log name & " v" & version

proc id(node: JsonNode): int =
    if node.kind == JObject: return node["id"].id()
    if node.kind == JString: return node.getStr().parseInt()
    if node.kind == JInt:    return node.getInt()
    
    raise newException(MalformedFrame, "Invalid id node: " & repr(node))

proc respond(request: JsonNode, data: JsonNode) =
    outs.sendJson(%* {
        "jsonrpc" : "2.0",
        "id" : request.id,
        "result" : data
    })

proc InitializeResult(name, version: string, capabilities: JsonNode) : JsonNode = %* {
        "serverInfo" : {
            "name" : name,
            "version" : version
        },
        "capabilities" :  capabilities
    }

proc InitializeResult(capabilities: JsonNode) : JsonNode = InitializeResult(name, version, capabilities)

while true:
    try:
        let message = ins.readJson()
    
        log "Got " & message["method"].getStr & " request"

        case message["method"].getStr:
            of "shutdown":
                message.respond(%* nil)
            of "initialize":
                log "root file " & parseUri(message["params"]["rootUri"].getStr).path
                message.respond(InitializeResult(%* {
                    
                }))
            of "initialized":
                log "served initialized"
            else:
                log "Unkown request type " & message["method"].getStr

    except IOError:
        break
    except CatchableError as e:
        log "Got exception: ", e.msg