import logging
import json
import jsonrpc

import src/validate
import src/reporter

const name = "gethen lsp"
const version = "0.0.0"

info name & " v" & version

converter toJson*(spot: ((int, int), (int, int))): JsonNode = %* {
        "start" : { "line" : spot[0][0], "character" : spot[0][1]  },
        "end"   : { "line" : spot[1][0], "character" : spot[1][1] }
    }

proc initializeResult(name, version: string, capabilities: JsonNode) : JsonNode = %* {
        "serverInfo" : {
            "name" : name,
            "version" : version
        },
        "capabilities" : capabilities
    }

proc validateDocument(uri: string, version: int, text: string, rpc: Jsonrpc) =
    let report = validate(text)
    
    var diagnostics = newSeq[JsonNode]()

    for diagnostic in report :
        diagnostics.add(%* {
            "source" : name,
            "range" : diagnostic.spot.toJson(),
            "severity" : diagnostic.lvl.toInt(),
            "message" : diagnostic.txt
        })

    rpc.notify("textDocument/publishDiagnostics", %* {
        "uri" : uri,
        "version" : version,
        "diagnostics" : diagnostics
    })
    
proc onRequest(message: RequestMessage, rpc: Jsonrpc): JsonNode =
    case message.action:

    of "shutdown":
        info "server shutting down"

        return %* nil

    of "initialize":
        info "server initializing"
        info "root file " & message.params["rootUri"].getStr()

        return initializeResult(name, version, %* {
            "textDocumentSync" : {
                "openClose" : true,
                "change" : 1 #2
            },
            # "completionProvider" : {
            #     "triggerCharacters" : [" ", "."],
            #     "allCommitCharacters" : ["."],

            #     "resolveProvider" : true,
            #     "workDoneProgress" : false
            # },
            "definitionProvider" : true,
            "hoverProvider" : true
        })

    else:
        error "unhandled request " & message.action

        return %* nil

proc onNotification(message: NotificationMessage, rpc: Jsonrpc) =
    case message.action:

    of "initialized":
        info "server initialized"

    of "textDocument/didOpen":
        info "opened " & message.params["textDocument"]["uri"].getStr()
        validateDocument(
            message.params["textDocument"]["uri"].getStr(),
            message.params["textDocument"]["version"].getInt(),
            message.params["textDocument"]["text"].getStr()
        , rpc)

    of "textDocument/didChange":
        info "edited " & message.params["textDocument"]["uri"].getStr()
        validateDocument(
            message.params["textDocument"]["uri"].getStr(),
            message.params["textDocument"]["version"].getInt(),
            message.params["contentChanges"][0]["text"].getStr()
        , rpc)

    of "textDocument/didClose":
        info "closed " & message.params["textDocument"]["uri"].getStr()

    else:
        info "unhandled notification: " & message.action

jsonrpc(onRequest, onNotification)