import streams
import loging
import os
import jsonstream
import json
import uri

include jsonrpc

const name = "omni lsp"
const version = "0.0.0"
const storage = currentSourcePath().parentDir / "tmp"

let ins  = newFileStream(stdin)
let outs = newFileStream(stdout)


# make sure that a tmp folder exist
discard existsOrCreateDir(storage)

log name & " v" & version

var currentId = 100000000

proc getNewId() : int =
    currentId += 1
    return currentId

proc path(node: JsonNode): string =
    if node.kind == JObject: return node["uri"].path()
    if node.kind == JString: return parseUri(node.getStr()).path
    
    raise newException(MalformedFrame, "Invalid id node: " & repr(node))

proc respond(request: JsonNode, data: JsonNode) =
    outs.sendJson(%* {
        "jsonrpc" : "2.0",
        "id" : request["id"],
        "result" : data
    })

proc request(meth: string, params: JsonNode) =
    outs.sendJson(%* {
        "id" : getNewId(),
        "method" : meth,
        "params" : params
    })

proc registration(meth: string, params: JsonNode): JsonNode = %* {
        "id" : getNewId(),
        "method" : meth,
        "registerOptions" : params
    }

proc InitializeResult(name, version: string, capabilities: JsonNode) : JsonNode = %* {
        "serverInfo" : {
            "name" : name,
            "version" : version
        },
        "capabilities" : capabilities
    }

proc InitializeResult(capabilities: JsonNode) : JsonNode = InitializeResult(name, version, capabilities)

while true:
    try:
        let message = ins.readJson()

        # log DEBUG, message

        onRequest(message):
            case message["method"].getStr():

            of "shutdown":
                log "shutting down server"
                message.respond(%* nil)

            of "initialize":
                # log "root file " & message["params"]["rootUri"].path

                message.respond(InitializeResult(%* {
                    "textDocumentSync" : {
                        "openClose" : true,
                        "change" : true
                    },
                    "completionProvider" : {
                        "triggerCharacters" : ["."],
                        "allCommitCharacters" : [" ", "."],

                        "resolveProvider" : true,
                        "workDoneProgress" : false
                    }
                }))

                request("client/registerCapability", %* {
                    "registrations" : [
                        registration("textDocument/willSaveWaitUntil", %* {
                            "documentSelector": [
                                { "language": "" }
                            ]
                        })
                    ]
                })

            else:
                log WARN, "Unhandled request " & message["method"].getStr()

        onNotification(message):
            case message["method"].getStr():

            of "initialized":
                log "served initialized"

            of "textDocument/didOpen":
                log "opened " & message["params"]["textDocument"].path

            of "textDocument/didClose":
                log "closed " & message["params"]["textDocument"].path

            else:
                log INFO, "got notification " & message["method"].getStr

        onResponse(message):
            log INFO, "got response" 

            log DEBUG, message
        
    except CatchableError:
        log ERROR, getCurrentExceptionMsg()
    except:
        log ERROR, getCurrentExceptionMsg()
        break

log "server closed"