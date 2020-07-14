import loging
import os
import json
import uri
# import threadpool
include jsonrpc

const name = "omni lsp"
const version = "0.0.0"
const storage = currentSourcePath().parentDir / "tmp"

# make sure that a tmp folder exist
discard existsOrCreateDir(storage)

log name & " v" & version

proc path(node: JsonNode): string =
    if node.kind == JObject: return node["uri"].path()
    if node.kind == JString: return parseUri(node.getStr()).path
    
    raise newException(MalformedFrame, "Invalid id node: " & repr(node))

# proc notify(meth: string, )

# proc registration(meth: string, params: JsonNode): JsonNode = %* {
#         "id" : getNewId(),
#         "method" : meth,
#         "registerOptions" : params
#     }

proc InitializeResult(name, version: string, capabilities: JsonNode) : JsonNode = %* {
        "serverInfo" : {
            "name" : name,
            "version" : version
        },
        "capabilities" : capabilities
    }

proc InitializeResult(capabilities: JsonNode) : JsonNode = InitializeResult(name, version, capabilities)

# proc validateDocument(document: JsonNode) =
#     let text = document["text"]

#     request()

proc onRequest(message: RequestMessage): JsonNode =
    case message["method"].getStr():

    of "shutdown":
        log "shutting down server"
        return %* nil

    of "initialize":
        # log "root file " & message["params"]["rootUri"].path

        return InitializeResult(%* {
            "textDocumentSync" : {
                "openClose" : true,
                "change" : true
            },
            "completionProvider" : {
                # "triggerCharacters" : ["."],
                # "allCommitCharacters" : [" ", "."],

                "resolveProvider" : true,
                # "workDoneProgress" : false
            }
        })

    else:
        log ERROR, "unhandled request " & message["method"].getStr()

        return %* nil

proc onNotification(message: NotificationMessage) =
    case message["method"].getStr():

    of "initialized":
        log "served initialized"

        # DidChangeConfigurationNotification.type

        # request("client/registerCapability", %* {
        #     "registrations" : [
        #         registration("textDocument/willSaveWaitUntil", %* nil)
        #     ]
        # })

    of "textDocument/didOpen":
        log "opened " & message["params"]["textDocument"].path
        # validateDocument(message["params"]["textDocument"])

    of "textDocument/didClose":
        log "closed " & message["params"]["textDocument"].path

    else:
        log INFO, "unhandled notification: " & message["method"].getStr

let rpc = newJsonrpc(onRequest, onNotification)