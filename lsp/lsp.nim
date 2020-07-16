import logging
import json
import jsonrpc
import nre

const name = "gethen lsp"
const version = "0.0.0"

info name & " v" & version

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

proc validateDocument(uri: string, version: int, text: string, rpc: Jsonrpc) =
    let lines = text.split(re"\n")

    var diagnostics = newSeq[JsonNode]()

    for range in lines.forAll( re"[0-9]+" ):
        diagnostics.add(%* {
            "range" : range,
            "severity" : 4,
            "source" : "gethen lsp",
            "message" : "is a number"
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

        return initializeResult(%* {
            "textDocumentSync" : {
                "openClose" : true,
                "change" : 2
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