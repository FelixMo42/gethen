import jsonschema

const EOL = ["\n", "\r\n", "\r"]

type
    ErrorCode = enum
        # defined by the lsp.
        ContentModified = -32801
        RequestCancelled = -32800

        # defined by jsonrpc
        ParseError = -32700
        InternalError = -32603
        InvalidParams = -32602
        MethodNotFound = -32601
        InvalidRequest = -32600
        ServerErrorStart = -32099
        ServerNotInitialized = -32002
        UnknownErrorCode = -32001
        ServerErrorEnd = -32000

    DiagnosticTag = enum
        Unnecessary = 1
        Deprecated  = 2

    DiagnosticSeverity = enum
        Error = 1
        Warning = 2
        Information = 3
        Hint = 4

jsonSchema :
    Message :
        jsonrpc : string

    RequestMessage extends Message :
        id : int or string
        "method" : string
        params ?: array or object

    ResponseMessage extends Message :
        id : int or string or null
        result ?: string or int or bool or object or null
        error ?: ResponseError

    ResponseError :
        code : ErrorCode
        message : string
        data ?: string or int or bool or array or object or null
 
    NotificationMessage extends Message :
        "method" : string
        params ?: array or object

    CancelParams :
        id : int or string

    # type ProgressToken = int or string
    #     ProgressParams<T> :
    #     token : ProgressToken
    #     value : T

    Position :
        line : int
        character : int

    Range :
        start : Position
        "end" : Position

    Location :
        uri : DocumentUri
        range : Range

    LocationLink :
        originSelectionRange ?: Range
        targetUri : DocumentUri
        targetRange : Range
        targetSelectionRange : Range

    Diagnostic :
        range : Range
        severity ?: DiagnosticSeverity
        code ?: int or string
        source ?: string
        message : string
        tags ?: DiagnosticTag[]
        relatedInformation ?: DiagnosticRelatedInformation[]
    
    DiagnosticRelatedInformation :
        location : Location
        message : string

    Command :
        title : string
        command : string
        arguments ?: any[]

    TextEdit :
        range : Range
        newText : string

    TextDocumentEdit :
        textDocument : VersionedTextDocumentIdentifier
        edits : TextEdit[]

    CreateFileOptions :
        overwrite ?: bool
        ignoreIfExists ?: bool

    CreateFile :
        kind : 'create'
        uri : DocumentUri
        options ?: CreateFileOptions

    RenameFileOptions :
        overwrite ?: bool
        ignoreIfExists ?: bool

    RenameFile :
        kind : 'rename'
        oldUri : DocumentUri
        newUri : DocumentUri
        options ?: RenameFileOptions

    DeleteFileOptions :
        recursive ?: bool
        ignoreIfNotExists ?: bool

    DeleteFile :
        kind : 'delete'
        uri : DocumentUri
        options ?: DeleteFileOptions

    WorkspaceEdit :
        changes ?: : [uri : DocumentUri] : TextEdit[] 
        documentChanges ?: (TextDocumentEdit[] or (TextDocumentEdit or CreateFile or RenameFile or DeleteFile)[])

    WorkspaceEditClientCapabilities :
        documentChanges ?: bool
        resourceOperations ?: ResourceOperationKind[]
        failureHandling ?: FailureHandlingKind

    type ResourceOperationKind = 'create' or 'rename' or 'delete'

    namespace ResourceOperationKind :
        const Create : ResourceOperationKind = 'create'
        const Rename : ResourceOperationKind = 'rename'
        const Delete : ResourceOperationKind = 'delete'

    type FailureHandlingKind = 'abort' or 'transactional' or 'undo' or 'textOnlyTransactional'

    namespace FailureHandlingKind :
        const Abort : FailureHandlingKind = 'abort'
        const Transactional : FailureHandlingKind = 'transactional'
        
        const TextOnlyTransactional : FailureHandlingKind = 'textOnlyTransactional'
        const Undo : FailureHandlingKind = 'undo'

    TextDocumentIdentifier :
        uri : DocumentUri

    TextDocumentItem :
        uri : DocumentUri
        languageId : string
        version : int
        text : string

    VersionedTextDocumentIdentifier extends TextDocumentIdentifier :
        version : int or null

    TextDocumentPositionParams :
        textDocument : TextDocumentIdentifier
        position : Position

    DocumentFilter :
        language ?: string
        scheme ?: string
        pattern ?: string

    type DocumentSelector = DocumentFilter[]

    StaticRegistrationOptions :
        id ?: string

    TextDocumentRegistrationOptions :
        documentSelector : DocumentSelector or null

    namespace MarkupKind :
        const PlainText : 'plaintext' = 'plaintext'
        const Markdown : 'markdown' = 'markdown'

    type MarkupKind = 'plaintext' or 'markdown'

    MarkupContent :
        kind : MarkupKind
        value : string

    WorkDoneProgressBegin :
        kind : 'begin'
        title : string
        cancellable ?: bool
        message ?: string
        percentage ?: int

    WorkDoneProgressReport :
        kind : 'report'
        cancellable ?: bool
        message ?: string
        percentage ?: int

    WorkDoneProgressEnd :
        kind : 'end'
        message ?: string

    WorkDoneProgressParams :
        workDoneToken ?: ProgressToken

    WorkDoneProgressOptions :
        workDoneProgress ?: bool

    PartialResultParams :
        partialResultToken ?: ProgressToken

    InitializeParams extends WorkDoneProgressParams :
        processId : int or null
        clientInfo ?: :
            name : string
            version ?: string
            rootPath ?: string or null
        rootUri : DocumentUri or null
        initializationOptions ?: any
        capabilities : ClientCapabilities
        trace ?: 'off' or 'messages' or 'verbose'
        workspaceFolders ?: WorkspaceFolder[] or null

    TextDocumentClientCapabilities :
        synchronization ?: TextDocumentSyncClientCapabilities
        completion ?: CompletionClientCapabilities
        hover ?: HoverClientCapabilities
        signatureHelp ?: SignatureHelpClientCapabilities
        declaration ?: DeclarationClientCapabilities
        definition ?: DefinitionClientCapabilities
        typeDefinition ?: TypeDefinitionClientCapabilities
        implementation ?: ImplementationClientCapabilities
        references ?: ReferenceClientCapabilities
        documentHighlight ?: DocumentHighlightClientCapabilities
        documentSymbol ?: DocumentSymbolClientCapabilities
        codeAction ?: CodeActionClientCapabilities
        codeLens ?: CodeLensClientCapabilities
        documentLink ?: DocumentLinkClientCapabilities
        colorProvider ?: DocumentColorClientCapabilities
        formatting ?: DocumentFormattingClientCapabilities
        rangeFormatting ?: DocumentRangeFormattingClientCapabilities
        onTypeFormatting ?: DocumentOnTypeFormattingClientCapabilities
        rename ?: RenameClientCapabilities
        publishDiagnostics ?: PublishDiagnosticsClientCapabilities
        foldingRange ?: FoldingRangeClientCapabilities
        selectionRange ?: SelectionRangeClientCapabilities

    ClientCapabilities :
        workspace ?: :
            applyEdit ?: bool
            workspaceEdit ?: WorkspaceEditClientCapabilities
            didChangeConfiguration ?: DidChangeConfigurationClientCapabilities
            didChangeWatchedFiles ?: DidChangeWatchedFilesClientCapabilities
            symbol ?: WorkspaceSymbolClientCapabilities
            executeCommand ?: ExecuteCommandClientCapabilities
            workspaceFolders ?: bool
            configuration ?: bool
        
        textDocument ?: TextDocumentClientCapabilities
        window ?: :
            workDoneProgress ?: bool
        
        experimental ?: any

    InitializeResult :
        capabilities : ServerCapabilities
        serverInfo ?: :
        name : string
        version ?: string


    namespace InitializeError :
        const unknownProtocolVersion : int = 1

    InitializeError :
        retry : bool

    ServerCapabilities :
        textDocumentSync ?: TextDocumentSyncOptions or int
        completionProvider ?: CompletionOptions
        hoverProvider ?: bool or HoverOptions
        signatureHelpProvider ?: SignatureHelpOptions
        declarationProvider ?: bool or DeclarationOptions or DeclarationRegistrationOptions
        definitionProvider ?: bool or DefinitionOptions
        typeDefinitionProvider ?: bool or TypeDefinitionOptions or TypeDefinitionRegistrationOptions
        implementationProvider ?: bool or ImplementationOptions or ImplementationRegistrationOptions
        referencesProvider ?: bool or ReferenceOptions
        documentHighlightProvider ?: bool or DocumentHighlightOptions
        documentSymbolProvider ?: bool or DocumentSymbolOptions
        codeActionProvider ?: bool or CodeActionOptions
        codeLensProvider ?: CodeLensOptions
        documentLinkProvider ?: DocumentLinkOptions
        colorProvider ?: bool or DocumentColorOptions or DocumentColorRegistrationOptions
        documentFormattingProvider ?: bool or DocumentFormattingOptions
        documentRangeFormattingProvider ?: bool or DocumentRangeFormattingOptions
        documentOnTypeFormattingProvider ?: DocumentOnTypeFormattingOptions
        renameProvider ?: bool or RenameOptions
        foldingRangeProvider ?: bool or FoldingRangeOptions or FoldingRangeRegistrationOptions
        executeCommandProvider ?: ExecuteCommandOptions
        selectionRangeProvider ?: bool or SelectionRangeOptions or SelectionRangeRegistrationOptions
        workspaceSymbolProvider ?: bool
        workspace ?: :
        workspaceFolders ?: WorkspaceFoldersServerCapabilities

        experimental ?: any

    InitializedParams :

    ShowMessageParams :
        type : int
        message : string

    namespace MessageType :
        const Error = 1
        const Warning = 2
        const Info = 3
        const Log = 4

    ShowMessageRequestParams :
        type : int
        message : string
        actions ?: MessageActionItem[]

    MessageActionItem :
        title : string

    LogMessageParams :
        type : int
        message : string

    WorkDoneProgressCreateParams :
        token : ProgressToken

    WorkDoneProgressCancelParams :
        token : ProgressToken

    Registration :
        id : string
        "method" : string
        registerOptions ?: any

    RegistrationParams :
        registrations : Registration[]

    Unregistration :
        id : string
        "method" : string

    UnregistrationParams :
        # This should correctly be named `unregistrations`. However changing this
        # is a breaking change and needs to wait until we deliver a 4.x version
        # of the specification.
        unregisterations : Unregistration[]

    WorkspaceFoldersServerCapabilities :
        supported ?: bool
        changeNotifications ?: string or bool

    WorkspaceFolder :
        uri : DocumentUri
        name : string

    DidChangeWorkspaceFoldersParams :
        event : WorkspaceFoldersChangeEvent

    WorkspaceFoldersChangeEvent :
        added : WorkspaceFolder[]
        removed : WorkspaceFolder[]

    DidChangeConfigurationClientCapabilities :
        dynamicRegistration ?: bool

    DidChangeConfigurationParams :
        settings : any

    ConfigurationParams :
        items : ConfigurationItem[]

    ConfigurationItem :
        scopeUri ?: DocumentUri
        section ?: string

    DidChangeWatchedFilesClientCapabilities :
        dynamicRegistration ?: bool

    DidChangeWatchedFilesRegistrationOptions :
        watchers : FileSystemWatcher[]

    FileSystemWatcher :
        globPattern : string
        kind ?: int

    namespace WatchKind :
        const Create = 1
        const Change = 2
        const Delete = 4

    DidChangeWatchedFilesParams :
        changes : FileEvent[]

    FileEvent :
        uri : DocumentUri
        type : int

    namespace FileChangeType :
        const Created = 1
        const Changed = 2
        const Deleted = 3

    WorkspaceSymbolClientCapabilities :
        dynamicRegistration ?: bool
        symbolKind ?: :
            valueSet ?: SymbolKind[]
        
    WorkspaceSymbolOptions extends WorkDoneProgressOptions :

    WorkspaceSymbolRegistrationOptions extends WorkspaceSymbolOptions :

    WorkspaceSymbolParams extends WorkDoneProgressParams, PartialResultParams :
        query : string

    ExecuteCommandClientCapabilities :
        dynamicRegistration ?: bool

    ExecuteCommandOptions extends WorkDoneProgressOptions :
        commands : string[]

    ExecuteCommandRegistrationOptions extends ExecuteCommandOptions :

    ExecuteCommandParams extends WorkDoneProgressParams :
        command : string
        arguments ?: any[]

    ApplyWorkspaceEditParams :
        label ?: string
        edit : WorkspaceEdit

    ApplyWorkspaceEditResponse :
        applied : bool
        failureReason ?: string

    namespace TextDocumentSyncKind :
        const None = 0
        const Full = 1
        const Incremental = 2

    TextDocumentSyncOptions :
        openClose ?: bool
        change ?: TextDocumentSyncKind

    DidOpenTextDocumentParams :
        textDocument : TextDocumentItem

    TextDocumentChangeRegistrationOptions extends TextDocumentRegistrationOptions :
        syncKind : TextDocumentSyncKind

    DidChangeTextDocumentParams :
        textDocument : VersionedTextDocumentIdentifier
        contentChanges : TextDocumentContentChangeEvent[]

    type TextDocumentContentChangeEvent = :
        range : Range
        rangeLength ?: int
        text : string
    or :
        text : string

    WillSaveTextDocumentParams :
        textDocument : TextDocumentIdentifier
        reason : int

    namespace TextDocumentSaveReason :
        const Manual = 1
        const AfterDelay = 2
        const FocusOut = 3

    SaveOptions :
        includeText ?: bool

    TextDocumentSaveRegistrationOptions extends TextDocumentRegistrationOptions :
        includeText ?: bool

    DidSaveTextDocumentParams :
        textDocument : TextDocumentIdentifier
        text ?: string

    DidCloseTextDocumentParams :
        textDocument : TextDocumentIdentifier

    TextDocumentSyncClientCapabilities :
        dynamicRegistration ?: bool
        willSave ?: bool
        willSaveWaitUntil ?: bool
        didSave ?: bool

    namespace TextDocumentSyncKind :
        const None = 0
        const Full = 1
        const Incremental = 2

    TextDocumentSyncOptions :
        openClose ?: bool
        change ?: int
        willSave ?: bool
        willSaveWaitUntil ?: bool
        save ?: bool or SaveOptions

    PublishDiagnosticsClientCapabilities :
        relatedInformation ?: bool
        tagSupport ?: :
            valueSet : DiagnosticTag[]
            versionSupport ?: bool

    PublishDiagnosticsParams :
        uri : DocumentUri
        version ?: int
        diagnostics : Diagnostic[]

    CompletionClientCapabilities :
        dynamicRegistration ?: bool
        completionItem ?: :
            snippetSupport ?: bool
            commitCharactersSupport ?: bool
            documentationFormat ?: MarkupKind[]
            deprecatedSupport ?: bool
            preselectSupport ?: bool
            tagSupport ?: :
                valueSet : CompletionItemTag[]
            
            completionItemKind ?: :
            valueSet ?: CompletionItemKind[]
            contextSupport ?: bool

    CompletionOptions extends WorkDoneProgressOptions :
        triggerCharacters ?: string[]
        allCommitCharacters ?: string[]
        resolveProvider ?: bool

    CompletionRegistrationOptions extends TextDocumentRegistrationOptions, CompletionOptions :

    CompletionParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams :
        context ?: CompletionContext

    namespace CompletionTriggerKind :
        const Invoked : 1 = 1
        const TriggerCharacter : 2 = 2
        const TriggerForIncompleteCompletions : 3 = 3

    type CompletionTriggerKind = 1 or 2 or 3
        
    CompletionContext :
        triggerKind : CompletionTriggerKind
        triggerCharacter ?: string

    CompletionList :
        isIncomplete : bool
        items : CompletionItem[]

    namespace InsertTextFormat :
        const PlainText = 1
        const Snippet = 2

    type InsertTextFormat = 1 or 2
    namespace CompletionItemTag :
        const Deprecated = 1

    type CompletionItemTag = 1
    CompletionItem :
        label : string
        kind ?: int
        tags ?: CompletionItemTag[]
        detail ?: string
        documentation ?: string or MarkupContent
        deprecated ?: bool
        preselect ?: bool
        sortText ?: string
        filterText ?: string
        insertText ?: string
        insertTextFormat ?: InsertTextFormat
        textEdit ?: TextEdit
        additionalTextEdits ?: TextEdit[]
        commitCharacters ?: string[]
        command ?: Command
        data ?: any

    namespace CompletionItemKind :
        const Text = 1
        const Method = 2
        const Function = 3
        const constructor = 4
        const Field = 5
        const Variable = 6
        const Class = 7
        const = 8
        const Module = 9
        const Property = 10
        const Unit = 11
        const Value = 12
        const Enum = 13
        const Keyword = 14
        const Snippet = 15
        const Color = 16
        const File = 17
        const Reference = 18
        const Folder = 19
        const EnumMember = 20
        const constant = 21
        const Struct = 22
        const Event = 23
        const Operator = 24
        const TypeParameter = 25

    HoverClientCapabilities :
        dynamicRegistration ?: bool
        contentFormat ?: MarkupKind[]

    HoverOptions extends WorkDoneProgressOptions :

    HoverRegistrationOptions extends TextDocumentRegistrationOptions, HoverOptions :

    HoverParams extends TextDocumentPositionParams, WorkDoneProgressParams :

    Hover :
        contents : MarkedString or MarkedString[] or MarkupContent
        range ?: Range

    type MarkedString = string or : language : string , value : string 
    SignatureHelpClientCapabilities :
        dynamicRegistration ?: bool
        signatureInformation ?: :
            documentationFormat ?: MarkupKind[]
            parameterInformation ?: :
                labelOffsetSupport ?: bool
                    contextSupport ?: bool

    SignatureHelpOptions extends WorkDoneProgressOptions :
        triggerCharacters ?: string[]
        retriggerCharacters ?: string[]

    SignatureHelpRegistrationOptions extends TextDocumentRegistrationOptions, SignatureHelpOptions :

    SignatureHelpParams extends TextDocumentPositionParams, WorkDoneProgressParams :
        context ?: SignatureHelpContext

    namespace SignatureHelpTriggerKind :
        const Invoked : 1 = 1
        const TriggerCharacter : 2 = 2
        const ContentChange : 3 = 3

    type SignatureHelpTriggerKind = 1 or 2 or 3
    SignatureHelpContext :
        triggerKind : SignatureHelpTriggerKind
        triggerCharacter ?: string
        isRetrigger : bool
        activeSignatureHelp ?: SignatureHelp

    SignatureHelp :
        signatures : SignatureInformation[]
        activeSignature ?: int
        activeParameter ?: int

    SignatureInformation :
        label : string
        documentation ?: string or MarkupContent
        parameters ?: ParameterInformation[]

    ParameterInformation :
        label : string or [int, int]
        documentation ?: string or MarkupContent

    DeclarationClientCapabilities :
        dynamicRegistration ?: bool
        linkSupport ?: bool

    DeclarationOptions extends WorkDoneProgressOptions :

    DeclarationRegistrationOptions extends DeclarationOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions  :

    DeclarationParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams :

    DefinitionClientCapabilities :
        dynamicRegistration ?: bool
        linkSupport ?: bool

    DefinitionOptions extends WorkDoneProgressOptions :

    DefinitionRegistrationOptions extends TextDocumentRegistrationOptions, DefinitionOptions :

    DefinitionParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams :

    TypeDefinitionClientCapabilities :
        dynamicRegistration ?: bool
        linkSupport ?: bool

    TypeDefinitionOptions extends WorkDoneProgressOptions :

    TypeDefinitionRegistrationOptions extends TextDocumentRegistrationOptions, TypeDefinitionOptions, StaticRegistrationOptions :

    TypeDefinitionParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams :

    ImplementationClientCapabilities :
        dynamicRegistration ?: bool
        linkSupport ?: bool

    ImplementationOptions extends WorkDoneProgressOptions :

    ImplementationRegistrationOptions extends TextDocumentRegistrationOptions, ImplementationOptions, StaticRegistrationOptions :

    ImplementationParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams :

    ReferenceClientCapabilities :
        dynamicRegistration ?: bool

    ReferenceOptions extends WorkDoneProgressOptions :

    ReferenceRegistrationOptions extends TextDocumentRegistrationOptions, ReferenceOptions :

    ReferenceParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams :
        context : ReferenceContext

    ReferenceContext :
        includeDeclaration : bool

    DocumentHighlightClientCapabilities :
        dynamicRegistration ?: bool

    DocumentHighlightOptions extends WorkDoneProgressOptions :

    DocumentHighlightRegistrationOptions extends TextDocumentRegistrationOptions, DocumentHighlightOptions :

    DocumentHighlightParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams :

    DocumentHighlight :
        range : Range
        kind ?: int

    namespace DocumentHighlightKind :
        const Text = 1
        const Read = 2
        const Write = 3

    DocumentSymbolClientCapabilities :
        dynamicRegistration ?: bool
        symbolKind ?: :
        valueSet ?: SymbolKind[]

        hierarchicalDocumentSymbolSupport ?: bool

    DocumentSymbolOptions extends WorkDoneProgressOptions :

    DocumentSymbolRegistrationOptions extends TextDocumentRegistrationOptions, DocumentSymbolOptions :

    DocumentSymbolParams extends WorkDoneProgressParams, PartialResultParams :
        textDocument : TextDocumentIdentifier

    namespace SymbolKind :
            const File = 1
            const Module = 2
            const Namespace = 3
            const Package = 4
            const Class = 5
            const Method = 6
            const Property = 7
            const Field = 8
            const     constructor = 9
            const Enum = 10
            const = 11
            const Function = 12
            const Variable = 13
            const     constant = 14
            const String = 15
            const Number = 16
            const Boolean = 17
            const Array = 18
            const Object = 19
            const Key = 20
            const Null = 21
            const EnumMember = 22
            const Struct = 23
            const Event = 24
            const Operator = 25
            const TypeParameter = 26

    DocumentSymbol :
        name : string
        detail ?: string
        kind : SymbolKind
        deprecated ?: bool
        range : Range
        selectionRange : Range
        children ?: DocumentSymbol[]

    SymbolInformation :
        name : string
        kind : SymbolKind
        deprecated ?: bool
        location : Location
        containerName ?: string

    CodeActionClientCapabilities :
        dynamicRegistration ?: bool
        codeActionLiteralSupport ?: :
        codeActionKind : :
        valueSet : CodeActionKind[]


        isPreferredSupport ?: bool

    CodeActionOptions extends WorkDoneProgressOptions :
        codeActionKinds ?: CodeActionKind[]

    CodeActionRegistrationOptions extends TextDocumentRegistrationOptions, CodeActionOptions :

    CodeActionParams extends WorkDoneProgressParams, PartialResultParams :
        textDocument : TextDocumentIdentifier
        range : Range
        context : CodeActionContext

    type CodeActionKind = string
    namespace CodeActionKind :
        const Empty : CodeActionKind = ''
        const QuickFix : CodeActionKind = 'quickfix'
        const Refactor : CodeActionKind = 'refactor'
        const RefactorExtract : CodeActionKind = 'refactor.extract'
        const RefactorInline : CodeActionKind = 'refactor.inline'
        const RefactorRewrite : CodeActionKind = 'refactor.rewrite'
        const Source : CodeActionKind = 'source'
        const SourceOrganizeImports : CodeActionKind = 'source.organizeImports'

    CodeActionContext :
        diagnostics : Diagnostic[]
        only ?: CodeActionKind[]

    CodeAction :
        title : string
        kind ?: CodeActionKind
        diagnostics ?: Diagnostic[]
        isPreferred ?: bool
        edit ?: WorkspaceEdit
        command ?: Command

    CodeLensClientCapabilities :
        dynamicRegistration ?: bool

    CodeLensOptions extends WorkDoneProgressOptions :
        resolveProvider ?: bool

    CodeLensRegistrationOptions extends TextDocumentRegistrationOptions, CodeLensOptions :

    CodeLensParams extends WorkDoneProgressParams, PartialResultParams :
        textDocument : TextDocumentIdentifier

    CodeLens :
        range : Range
        command ?: Command
        data ?: any

    DocumentLinkClientCapabilities :
        dynamicRegistration ?: bool
        tooltipSupport ?: bool

    DocumentLinkOptions extends WorkDoneProgressOptions :
        resolveProvider ?: bool

    DocumentLinkRegistrationOptions extends TextDocumentRegistrationOptions, DocumentLinkOptions :

    DocumentLinkParams extends WorkDoneProgressParams, PartialResultParams :
        textDocument : TextDocumentIdentifier

    DocumentLink :
        range : Range
        target ?: DocumentUri
        tooltip ?: string
        data ?: any

    DocumentColorClientCapabilities :
        dynamicRegistration ?: bool

    DocumentColorOptions extends WorkDoneProgressOptions :

    DocumentColorRegistrationOptions extends TextDocumentRegistrationOptions, StaticRegistrationOptions, DocumentColorOptions :

    DocumentColorParams extends WorkDoneProgressParams, PartialResultParams :
        textDocument : TextDocumentIdentifier

    ColorInformation :
        range : Range
        color : Color

    Color :
        readonly red : int
        readonly green : int
        readonly blue : int
        readonly alpha : int

    ColorPresentationParams extends WorkDoneProgressParams, PartialResultParams :
        textDocument : TextDocumentIdentifier
        color : Color
        range : Range

    ColorPresentation :
        label : string
        textEdit ?: TextEdit
        additionalTextEdits ?: TextEdit[]

    DocumentFormattingClientCapabilities :
        dynamicRegistration ?: bool

    DocumentFormattingOptions extends WorkDoneProgressOptions :

    DocumentFormattingRegistrationOptions extends TextDocumentRegistrationOptions, DocumentFormattingOptions :

    DocumentFormattingParams extends WorkDoneProgressParams :
        textDocument : TextDocumentIdentifier
        options : FormattingOptions

    FormattingOptions :
        tabSize : int
        insertSpaces : bool
        trimTrailingWhitespace ?: bool
        insertFinalNewline ?: bool
        trimFinalNewlines ?: bool
        [key : string] : bool or int or string

    DocumentRangeFormattingClientCapabilities :
        dynamicRegistration ?: bool

    DocumentRangeFormattingOptions extends WorkDoneProgressOptions :

    DocumentRangeFormattingRegistrationOptions extends TextDocumentRegistrationOptions, DocumentRangeFormattingOptions :

    DocumentRangeFormattingParams extends WorkDoneProgressParams :
        textDocument : TextDocumentIdentifier
        range : Range
        options : FormattingOptions

    DocumentOnTypeFormattingClientCapabilities :
        dynamicRegistration ?: bool

    DocumentOnTypeFormattingOptions :
        firstTriggerCharacter : string
        moreTriggerCharacter ?: string[]

    DocumentOnTypeFormattingRegistrationOptions extends TextDocumentRegistrationOptions, DocumentOnTypeFormattingOptions :

    DocumentOnTypeFormattingParams extends TextDocumentPositionParams :
        ch : string
        options : FormattingOptions

    RenameClientCapabilities :
        dynamicRegistration ?: bool
        prepareSupport ?: bool

    RenameOptions extends WorkDoneProgressOptions :
        prepareProvider ?: bool

    RenameRegistrationOptions extends TextDocumentRegistrationOptions, RenameOptions :

    RenameParams extends TextDocumentPositionParams, WorkDoneProgressParams :
        newName : string

    PrepareRenameParams extends TextDocumentPositionParams :

    FoldingRangeClientCapabilities :
        dynamicRegistration ?: bool
        rangeLimit ?: int
        lineFoldingOnly ?: bool

    FoldingRangeOptions extends WorkDoneProgressOptions :

    FoldingRangeRegistrationOptions extends TextDocumentRegistrationOptions, FoldingRangeOptions, StaticRegistrationOptions :

    FoldingRangeParams extends WorkDoneProgressParams, PartialResultParams :
        textDocument : TextDocumentIdentifier

    enum FoldingRangeKind :
        Comment = 'comment',
        Imports = 'imports',
        Region = 'region'

    FoldingRange :
        startLine : int
        startCharacter ?: int
        endLine : int
        endCharacter ?: int
        kind ?: string

    SelectionRangeClientCapabilities :
        dynamicRegistration ?: bool

    SelectionRangeOptions extends WorkDoneProgressOptions :

    SelectionRangeRegistrationOptions extends SelectionRangeOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions :

    SelectionRangeParams extends WorkDoneProgressParams, PartialResultParams :
        textDocument : TextDocumentIdentifier
        positions : Position[]

    SelectionRange :
        range : Range
        parent ?: SelectionRange
    