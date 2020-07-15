import loging
import os
import json
import jsonrpc
import json
import nre

const name = "omni lsp"
const version = "0.0.0"
const storage = currentSourcePath().parentDir / "tmp"

# make sure that a tmp folder exist
discard existsOrCreateDir(storage)

log name & " v" & version

proc initializeResult(name, version: string, capabilities: JsonNode) : JsonNode = %* {
        "serverInfo" : {
            "name" : name,
            "version" : version
        },
        "capabilities" : capabilities
    }

proc initializeResult(capabilities: JsonNode) : JsonNode = initializeResult(name, version, capabilities)

iterator forAll(lines: seq[string], reg: Regex): JsonNode =
    for i , line in lines:
        var index = 0

        while true:
            if index == line.len:
                break

            let match = line.find(reg, index)

            if match.isNone:
                break

            let bounds = match.get.matchBounds
            
            index = bounds.b + 1

            yield %* {
                "start" : {
                    "line" : i,
                    "character" : bounds.a
                },
                "end" : {
                    "line" : i,
                    "character" : bounds.b + 1
                }
            }

proc validateDocument(doc: JsonNode, rpc: Jsonrpc) =
    let lines = doc["text"].getStr().split(re"\n")

    var diagnostics = newSeq[JsonNode]()

    for range in lines.forAll( re"[0-9]+" ):
        diagnostics.add(% {
            "range" : range,
            "severity" : %4,
            "source" : %"lsp",
            "message" : %"is a number"
        })

    # log DEBUG, %* {
    #     "uri" : doc["uri"],
    #     "version" : doc["version"],
    #     "diagnostics" : diagnostics
    # }

    rpc.notify("textDocument/publishDiagnostics", %* {
        "uri" : doc["uri"],
        "version" : doc["version"],
        "diagnostics" : diagnostics
    })

proc onRequest(message: RequestMessage, rpc: Jsonrpc): JsonNode =
    case message.action:

    of "shutdown":
        log "shutting down server"

        return %* nil

    of "initialize":
        # log "root file " & message["params"]["rootUri"].path

        return initializeResult(%* {
            "textDocumentSync" : {
                "openClose" : true,
                "change" : true
            },
            "completionProvider" : {
                "triggerCharacters" : [" ", "."],
                "allCommitCharacters" : ["."],

                "resolveProvider" : true,
                "workDoneProgress" : false
            },
            "definitionProvider" : true,
            "hoverProvider" : true
        })

    else:
        log ERROR, "unhandled request " & message.action

        return %* nil

proc onNotification(message: NotificationMessage, rpc: Jsonrpc) =
    case message.action:

    of "initialized":
        log "served initialized"

    of "textDocument/didOpen":
        log "opened " & message.params["textDocument"]["uri"].getStr()
        validateDocument(message.params["textDocument"], rpc)

    of "textDocument/didClose":
        log "closed " & message.params["textDocument"]["uri"].getStr()

    else:
        log "unhandled notification: " & message.action

jsonrpc(onRequest, onNotification)