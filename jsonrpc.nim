type 
    ErrorCodes* = enum
        # defined by the protocol.
        ContentModified = -32801,
        RequestCancelled = -32800,

        # base jsonrpc errors
        ParseError = -32700,
        InternalError = -32603,
        InvalidParams = -32602,
        MethodNotFound = -32601,
        InvalidRequest = -32600,
        ServerErrorStart = -32099,
        ServerNotInitialized = -32002,
        UnknownErrorCode = -32001,
        ServerErrorEnd = -32000

    DiagnosticSeverity* = enum
        Error = 1,
        Warning = 2,
        Information = 3,
        Hint = 4

    DiagnosticTag* = enum
        Unnecessary = 1,
        Deprecated = 2

    DocumentUri = string

    # ProgressToken = int or string

# not implementing progress support



jsonSchema:
    

    # positional types

    # diagnostics

    Diagnostic:
        range : Range
        severity ?: int
        code ?: int or string
        source ?: string
        message : string
        tags ?: int[]
        relatedInformation ?: DiagnosticRelatedInformation[]

    DiagnosticRelatedInformation:
        location: Location
        message: string

    # misc

    Command:
        title: string
        command: string
        arguments ?: any[]

    # text document managment

    TextEdit:
        "range": Range
        newText: string

    TextDocumentIdentifier:
        uri: DocumentUri

    VersionedTextDocumentIdentifier extends TextDocumentIdentifier:
        version: int or nil

    TextDocumentEdit:
        textDocument: VersionedTextDocumentIdentifier
        edits: TextEdit[]

    # file system managment

    CreateFileOptions:
        overwrite ?: bool
        ignoreIfExists ?: bool

    # # word done

    # WorkDoneProgressParams:
    #     workDoneToken ?: ProgressToken

    # # server capabilities

    # WorkspaceEditClientCapabilities:
    #     documentChanges ?: bool
    #     resourceOperations ?: ResourceOperationKind[]

    # WorkspaceClientCapabilities:
    #     applyEdit ?: bool
    #     workspaceEdit ?: WorkspaceEditClientCapabilities
    #     didChangeConfiguration ?: DidChangeConfigurationClientCapabilities
    #     didChangeWatchedFiles ?: DidChangeWatchedFilesClientCapabilities
    #     symbol ?: WorkspaceSymbolClientCapabilities
    #     executeCommand ?: ExecuteCommandClientCapabilities
    #     workspaceFolders ?: bool
    #     configuration ?: bool

    # ApplyWorkspaceEditParams:
    #     label ?: string
    #     edit: WorkspaceEdit

    # TextDocumentSyncClientCapabilities:
    #     dynamicRegistration ?: bool
    #     willSave ?: bool
    #     willSaveWaitUntil ?: bool
    #     didSave ?: bool

    # CompletionClientCapabilitiesItem:
    #     snippetSupport ?: bool

    # CompletionClientCapabilitiesItemKind:
    #     valueSet ?: CompletionItemKind[]

    # CompletionClientCapabilities:
    #     dynamicRegistration ?: bool
    #     completionItem ?: CompletionClientCapabilitiesItem
    #     completionItemKind ?: CompletionClientCapabilitiesItemKind
    #     contextSupport ?: bool

    # TextDocumentClientCapabilities:
    #     synchronization ?: TextDocumentSyncClientCapabilities
    #     completion ?: CompletionClientCapabilities
    #     hover ?: HoverClientCapabilities
    #     signatureHelp ?: SignatureHelpClientCapabilities
    #     declaration ?: DeclarationClientCapabilities
    #     definition ?: DefinitionClientCapabilities
    #     typeDefinition ?: TypeDefinitionClientCapabilities
    #     implementation ?: ImplementationClientCapabilities
    #     references ?: ReferenceClientCapabilities
    #     documentHighlight ?: DocumentHighlightClientCapabilities
    #     documentSymbol ?: DocumentSymbolClientCapabilities
    #     codeAction ?: CodeActionClientCapabilities
    #     codeLens ?: CodeLensClientCapabilities
    #     documentLink ?: DocumentLinkClientCapabilities
    #     colorProvider ?: DocumentColorClientCapabilities
    #     formatting ?: DocumentFormattingClientCapabilities
    #     rangeFormatting ?: DocumentRangeFormattingClientCapabilities
    #     onTypeFormatting ?: DocumentOnTypeFormattingClientCapabilities
    #     rename ?: RenameClientCapabilities
    #     publishDiagnostics ?: PublishDiagnosticsClientCapabilities
    #     foldingRange ?: FoldingRangeClientCapabilities
    #     selectionRange ?: SelectionRangeClientCapabilities

    # WindowClientCapabilities:
    #     workDoneProgress ?: bool

    # ClientCapabilities:
    #     workspace ?: WorkspaceClientCapabilities
    #     textDocument ?: TextDocumentClientCapabilities
    #     window ?: WindowClientCapabilities
    #     experimental ?: any