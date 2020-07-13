import streams
import loging
import os
import jsonstream
import strutils

include jsonrpc

const version = "0.0.0"
const storage = currentSourcePath().parentDir / "tmp"

let ins  = newFileStream(stdin)
let outs = newFileStream(stdout)


# make sure that a tmp folder exist
discard existsOrCreateDir(storage)

log "version: " & version

template whenValid(data, kind, body) =
    if data.isValid(kind, allowExtra = true):
        var data = kind(data)
        body
    else:
        debugEcho("Unable to parse data as " & $kind)

proc parseId(node: JsonNode): int =
    if node.kind == JString:
        node.getStr().parseInt()
    elif node.kind == JInt:
        node.getInt()
    else:
        raise newException(MalformedFrame, "Invalid id node: " & repr(node))

proc respond(request: RequestMessage, data: JsonNode) =
    outs.sendJson create(ResponseMessage, "2.0", parseId(request["id"]), some(data), none(ResponseError)).JsonNode

while true:
    try:
        let message = ins.readJson()
    
        whenValid(message, RequestMessage):
            log "Get " & message["method"].getStr & " request"

            case message["method"].getStr:
                of "shutdown":
                    
                of "initialize":
                    message.respond(create(InitializeResult, create(ServerCapabilities,
                        textDocumentSync = some(create(TextDocumentSyncOptions,
                            openClose = some(true),
                            change = some(TextDocumentSyncKind.Full.int),
                            willSave = some(false),
                            willSaveWaitUntil = some(false),
                            save = some(create(SaveOptions, some(true)))
                        )), # ?: TextDocumentSyncOptions or int or float
                        hoverProvider = some(true), # ?: bool
                        completionProvider = some(create(CompletionOptions,
                            resolveProvider = some(true),
                            triggerCharacters = some(@[".", " "])
                        )), # ?: CompletionOptions
                        signatureHelpProvider = none(SignatureHelpOptions),
                        definitionProvider = some(true), #?: bool
                        typeDefinitionProvider = none(bool), #?: bool or TextDocumentAndStaticRegistrationOptions
                        implementationProvider = none(bool), #?: bool or TextDocumentAndStaticRegistrationOptions
                        referencesProvider = some(true), #?: bool
                        documentHighlightProvider = none(bool), #?: bool
                        documentSymbolProvider = none(bool), #?: bool
                        workspaceSymbolProvider = none(bool), #?: bool
                        codeActionProvider = none(bool), #?: bool
                        codeLensProvider = none(CodeLensOptions), #?: CodeLensOptions
                        documentFormattingProvider = none(bool), #?: bool
                        documentRangeFormattingProvider = none(bool), #?: bool
                        documentOnTypeFormattingProvider = none(DocumentOnTypeFormattingOptions), #?: DocumentOnTypeFormattingOptions
                        renameProvider = some(true), #?: bool
                        documentLinkProvider = none(DocumentLinkOptions), #?: DocumentLinkOptions
                        colorProvider = none(bool), #?: bool or ColorProviderOptions or TextDocumentAndStaticRegistrationOptions
                        executeCommandProvider = none(ExecuteCommandOptions), #?: ExecuteCommandOptions
                        workspace = none(WorkspaceCapability), #?: WorkspaceCapability
                        experimental = none(JsonNode) #?: any
                    )).JsonNode)
                else:
                    log "Unkown request type " & message["method"].getStr


    except IOError:
        break
    except CatchableError as e:
        log "Got exception: ", e.msg