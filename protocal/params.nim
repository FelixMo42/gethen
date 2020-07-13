import jsonschema, options, json, sequtils

include location

type ProgressToken = int or string

jsonSchema:
    CancelParams:
        id : int or string

    WorkDoneProgressParams:
        workDoneToken ?: ProgressToken

    InitializeParams extends WorkDoneProgressParams:
        processId: int or nil
        rootPath ?: string or nil
        rootUri : DocumentUri
        initializationOptions ?: any
        capabilities : ClientCapabilities
        trace ?: string # 'off' or 'messages' or 'verbose'
        workspaceFolders ?: WorkspaceFolder[] or nil