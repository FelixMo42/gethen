interface Message {
    jsonrpc: string
}

interface RequestMessage extends Message {
    id: number | string
    method: string
    params?: array | object
}

interface ResponseMessage extends Message {
    id: number | string | null
    result?: string | number | boolean | object | null
    error?: ResponseError
}

interface ResponseError {
    code: number
    message: string
    data?: string | number | boolean | array | object | null
}

namespace ErrorCodes {
    // Defined by JSON RPC
    const ParseError: number = -32700
    const InvalidRequest: number = -32600
    const MethodNotFound: number = -32601
    const InvalidParams: number = -32602
    const InternalError: number = -32603
    const serverErrorStart: number = -32099
    const serverErrorEnd: number = -32000
    const ServerNotInitialized: number = -32002
    const UnknownErrorCode: number = -32001
    // Defined by the protocol.
    const RequestCancelled: number = -32800
    const ContentModified: number = -32801
}

interface NotificationMessage extends Message {
    method: string
    params?: array | object
}

interface CancelParams {
    id: number | string
}

type ProgressToken = number | string
    interface ProgressParams<T> {
    token: ProgressToken
    value: T
}

type DocumentUri = string

const EOL: string[] = ['\n', '\r\n', '\r']

interface Position {
    line: number
    character: number
}

interface Range {
    start: Position
    end: Position
}

interface Location {
    uri: DocumentUri
    range: Range
}

interface LocationLink {
    originSelectionRange?: Range
    targetUri: DocumentUri
    targetRange: Range
    targetSelectionRange: Range
}

interface Diagnostic {
    range: Range
    severity?: DiagnosticSeverity
    code?: number | string
    source?: string
    message: string
    tags?: DiagnosticTag[]
    relatedInformation?: DiagnosticRelatedInformation[]
}

namespace DiagnosticSeverity {
    const Error: 1 = 1
    const Warning: 2 = 2
    const Information: 3 = 3
    const Hint: 4 = 4
}

type DiagnosticSeverity = 1 | 2 | 3 | 4

namespace DiagnosticTag {
    const Unnecessary: 1 = 1
    const Deprecated: 2 = 2
}

type DiagnosticTag = 1 | 2
interface DiagnosticRelatedInformation {
    location: Location
    message: string
}

interface Command {
    title: string
    command: string
    arguments?: any[]
}

interface TextEdit {
    range: Range
    newText: string
}

interface TextDocumentEdit {
    textDocument: VersionedTextDocumentIdentifier
    edits: TextEdit[]
}

interface CreateFileOptions {
    overwrite?: boolean
    ignoreIfExists?: boolean
}

interface CreateFile {
    kind: 'create'
    uri: DocumentUri
    options?: CreateFileOptions
}

interface RenameFileOptions {
    overwrite?: boolean
    ignoreIfExists?: boolean
}

interface RenameFile {
    kind: 'rename'
    oldUri: DocumentUri
    newUri: DocumentUri
    options?: RenameFileOptions
}

interface DeleteFileOptions {
    recursive?: boolean
    ignoreIfNotExists?: boolean
}

interface DeleteFile {
    kind: 'delete'
    uri: DocumentUri
    options?: DeleteFileOptions
}

interface WorkspaceEdit {
    changes?: { [uri: DocumentUri]: TextEdit[] }

    documentChanges?: (TextDocumentEdit[] | (TextDocumentEdit | CreateFile | RenameFile | DeleteFile)[])
}

interface WorkspaceEditClientCapabilities {
    documentChanges?: boolean
    resourceOperations?: ResourceOperationKind[]
    failureHandling?: FailureHandlingKind
}

type ResourceOperationKind = 'create' | 'rename' | 'delete'

namespace ResourceOperationKind {
    const Create: ResourceOperationKind = 'create'
    const Rename: ResourceOperationKind = 'rename'
    const Delete: ResourceOperationKind = 'delete'
}

type FailureHandlingKind = 'abort' | 'transactional' | 'undo' | 'textOnlyTransactional'

namespace FailureHandlingKind {
    const Abort: FailureHandlingKind = 'abort'
    const Transactional: FailureHandlingKind = 'transactional'
    
    const TextOnlyTransactional: FailureHandlingKind = 'textOnlyTransactional'
    const Undo: FailureHandlingKind = 'undo'
}

interface TextDocumentIdentifier {
    uri: DocumentUri
}

interface TextDocumentItem {
    uri: DocumentUri
    languageId: string
    version: number
    text: string
}

interface VersionedTextDocumentIdentifier extends TextDocumentIdentifier {
    version: number | null
}

interface TextDocumentPositionParams {
    textDocument: TextDocumentIdentifier
    position: Position
}

interface DocumentFilter {
    language?: string
    scheme?: string
    pattern?: string
}

type DocumentSelector = DocumentFilter[]

interface StaticRegistrationOptions {
    id?: string
}

interface TextDocumentRegistrationOptions {
    documentSelector: DocumentSelector | null
}

namespace MarkupKind {
    const PlainText: 'plaintext' = 'plaintext'
    const Markdown: 'markdown' = 'markdown'
}

type MarkupKind = 'plaintext' | 'markdown'

interface MarkupContent {
    kind: MarkupKind
    value: string
}

interface WorkDoneProgressBegin {
    kind: 'begin'
    title: string
    cancellable?: boolean
    message?: string
    percentage?: number
}

interface WorkDoneProgressReport {
    kind: 'report'
    cancellable?: boolean
    message?: string
    percentage?: number
}

interface WorkDoneProgressEnd {
    kind: 'end'
    message?: string
}

interface WorkDoneProgressParams {
    workDoneToken?: ProgressToken
}

interface WorkDoneProgressOptions {
    workDoneProgress?: boolean
}

interface PartialResultParams {
    partialResultToken?: ProgressToken
}

interface InitializeParams extends WorkDoneProgressParams {
    processId: number | null
    clientInfo?: {
        name: string
        version?: string
    }
    rootPath?: string | null
    rootUri: DocumentUri | null
    initializationOptions?: any
    capabilities: ClientCapabilities
    trace?: 'off' | 'messages' | 'verbose'
    workspaceFolders?: WorkspaceFolder[] | null
}

interface TextDocumentClientCapabilities {
    synchronization?: TextDocumentSyncClientCapabilities
    completion?: CompletionClientCapabilities
    hover?: HoverClientCapabilities
    signatureHelp?: SignatureHelpClientCapabilities
    declaration?: DeclarationClientCapabilities
    definition?: DefinitionClientCapabilities
    typeDefinition?: TypeDefinitionClientCapabilities
    implementation?: ImplementationClientCapabilities
    references?: ReferenceClientCapabilities
    documentHighlight?: DocumentHighlightClientCapabilities
    documentSymbol?: DocumentSymbolClientCapabilities
    codeAction?: CodeActionClientCapabilities
    codeLens?: CodeLensClientCapabilities
    documentLink?: DocumentLinkClientCapabilities
    colorProvider?: DocumentColorClientCapabilities
    formatting?: DocumentFormattingClientCapabilities
    rangeFormatting?: DocumentRangeFormattingClientCapabilities
    onTypeFormatting?: DocumentOnTypeFormattingClientCapabilities
    rename?: RenameClientCapabilities
    publishDiagnostics?: PublishDiagnosticsClientCapabilities
    foldingRange?: FoldingRangeClientCapabilities
    selectionRange?: SelectionRangeClientCapabilities
}

interface ClientCapabilities {
    workspace?: {
        applyEdit?: boolean
        workspaceEdit?: WorkspaceEditClientCapabilities
        didChangeConfiguration?: DidChangeConfigurationClientCapabilities
        didChangeWatchedFiles?: DidChangeWatchedFilesClientCapabilities
        symbol?: WorkspaceSymbolClientCapabilities
        executeCommand?: ExecuteCommandClientCapabilities
        workspaceFolders?: boolean
        configuration?: boolean
    }

    textDocument?: TextDocumentClientCapabilities
    window?: {
        workDoneProgress?: boolean
    }

    experimental?: any
}

interface InitializeResult {
    capabilities: ServerCapabilities
    serverInfo?: {
    name: string
    version?: string
}

}

namespace InitializeError {
    const unknownProtocolVersion: number = 1
}

interface InitializeError {
    retry: boolean
}

interface ServerCapabilities {
    textDocumentSync?: TextDocumentSyncOptions | number
    completionProvider?: CompletionOptions
    hoverProvider?: boolean | HoverOptions
    signatureHelpProvider?: SignatureHelpOptions
    declarationProvider?: boolean | DeclarationOptions | DeclarationRegistrationOptions
    definitionProvider?: boolean | DefinitionOptions
    typeDefinitionProvider?: boolean | TypeDefinitionOptions | TypeDefinitionRegistrationOptions
    implementationProvider?: boolean | ImplementationOptions | ImplementationRegistrationOptions
    referencesProvider?: boolean | ReferenceOptions
    documentHighlightProvider?: boolean | DocumentHighlightOptions
    documentSymbolProvider?: boolean | DocumentSymbolOptions
    codeActionProvider?: boolean | CodeActionOptions
    codeLensProvider?: CodeLensOptions
    documentLinkProvider?: DocumentLinkOptions
    colorProvider?: boolean | DocumentColorOptions | DocumentColorRegistrationOptions
    documentFormattingProvider?: boolean | DocumentFormattingOptions
    documentRangeFormattingProvider?: boolean | DocumentRangeFormattingOptions
    documentOnTypeFormattingProvider?: DocumentOnTypeFormattingOptions
    renameProvider?: boolean | RenameOptions
    foldingRangeProvider?: boolean | FoldingRangeOptions | FoldingRangeRegistrationOptions
    executeCommandProvider?: ExecuteCommandOptions
    selectionRangeProvider?: boolean | SelectionRangeOptions | SelectionRangeRegistrationOptions
    workspaceSymbolProvider?: boolean
    workspace?: {
    workspaceFolders?: WorkspaceFoldersServerCapabilities
}

    experimental?: any
}

interface InitializedParams {
}

interface ShowMessageParams {
    type: number
    message: string
}

namespace MessageType {
    const Error = 1
    const Warning = 2
    const Info = 3
    const Log = 4
}

interface ShowMessageRequestParams {
    type: number
    message: string
    actions?: MessageActionItem[]
}

interface MessageActionItem {
    title: string
}

interface LogMessageParams {
    type: number
    message: string
}

interface WorkDoneProgressCreateParams {
    token: ProgressToken
}

interface WorkDoneProgressCancelParams {
    token: ProgressToken
}

interface Registration {
    id: string
    method: string
    registerOptions?: any
}

interface RegistrationParams {
    registrations: Registration[]
}

interface Unregistration {
    id: string
    method: string
}

interface UnregistrationParams {
    // This should correctly be named `unregistrations`. However changing this
    // is a breaking change and needs to wait until we deliver a 4.x version
    // of the specification.
    unregisterations: Unregistration[]
}

interface WorkspaceFoldersServerCapabilities {
    supported?: boolean
    changeNotifications?: string | boolean
}

interface WorkspaceFolder {
    uri: DocumentUri
    name: string
}

interface DidChangeWorkspaceFoldersParams {
    event: WorkspaceFoldersChangeEvent
}

interface WorkspaceFoldersChangeEvent {
    added: WorkspaceFolder[]
    removed: WorkspaceFolder[]
}

interface DidChangeConfigurationClientCapabilities {
    dynamicRegistration?: boolean
}

interface DidChangeConfigurationParams {
    settings: any
}

interface ConfigurationParams {
    items: ConfigurationItem[]
}

interface ConfigurationItem {
    scopeUri?: DocumentUri
    section?: string
}

interface DidChangeWatchedFilesClientCapabilities {
    dynamicRegistration?: boolean
}

interface DidChangeWatchedFilesRegistrationOptions {
    watchers: FileSystemWatcher[]
}

interface FileSystemWatcher {
    globPattern: string
    kind?: number
}

namespace WatchKind {
    const Create = 1
    const Change = 2
    const Delete = 4
}

interface DidChangeWatchedFilesParams {
    changes: FileEvent[]
}

interface FileEvent {
    uri: DocumentUri
    type: number
}

namespace FileChangeType {
    const Created = 1
    const Changed = 2
    const Deleted = 3
}

interface WorkspaceSymbolClientCapabilities {
    dynamicRegistration?: boolean
    symbolKind?: {
        valueSet?: SymbolKind[]
    }
}

interface WorkspaceSymbolOptions extends WorkDoneProgressOptions {
}

interface WorkspaceSymbolRegistrationOptions extends WorkspaceSymbolOptions {
}

interface WorkspaceSymbolParams extends WorkDoneProgressParams, PartialResultParams {
    query: string
}

interface ExecuteCommandClientCapabilities {
    dynamicRegistration?: boolean
}

interface ExecuteCommandOptions extends WorkDoneProgressOptions {
    commands: string[]
}

interface ExecuteCommandRegistrationOptions extends ExecuteCommandOptions {
}

interface ExecuteCommandParams extends WorkDoneProgressParams {
    command: string
    arguments?: any[]
}

interface ApplyWorkspaceEditParams {
    label?: string
    edit: WorkspaceEdit
}

interface ApplyWorkspaceEditResponse {
    applied: boolean
    failureReason?: string
}

namespace TextDocumentSyncKind {
    const None = 0
    const Full = 1
    const Incremental = 2
}

interface TextDocumentSyncOptions {
    openClose?: boolean
    change?: TextDocumentSyncKind
}

interface DidOpenTextDocumentParams {
    textDocument: TextDocumentItem
}

interface TextDocumentChangeRegistrationOptions extends TextDocumentRegistrationOptions {
    syncKind: TextDocumentSyncKind
}

interface DidChangeTextDocumentParams {
    textDocument: VersionedTextDocumentIdentifier
    contentChanges: TextDocumentContentChangeEvent[]
}

type TextDocumentContentChangeEvent = {
    range: Range
    rangeLength?: number
    text: string
}
 | {
    text: string
}

interface WillSaveTextDocumentParams {
    textDocument: TextDocumentIdentifier
    reason: number
}

namespace TextDocumentSaveReason {
    const Manual = 1
    const AfterDelay = 2
    const FocusOut = 3
}

interface SaveOptions {
    includeText?: boolean
}

interface TextDocumentSaveRegistrationOptions extends TextDocumentRegistrationOptions {
    includeText?: boolean
}

interface DidSaveTextDocumentParams {
    textDocument: TextDocumentIdentifier
    text?: string
}

interface DidCloseTextDocumentParams {
    textDocument: TextDocumentIdentifier
}

interface TextDocumentSyncClientCapabilities {
    dynamicRegistration?: boolean
    willSave?: boolean
    willSaveWaitUntil?: boolean
    didSave?: boolean
}

namespace TextDocumentSyncKind {
    const None = 0
    const Full = 1
    const Incremental = 2
}

interface TextDocumentSyncOptions {
    openClose?: boolean
    change?: number
    willSave?: boolean
    willSaveWaitUntil?: boolean
    save?: boolean | SaveOptions
}

interface PublishDiagnosticsClientCapabilities {
    relatedInformation?: boolean
    tagSupport?: {
        valueSet: DiagnosticTag[]
    }
    versionSupport?: boolean
}

interface PublishDiagnosticsParams {
    uri: DocumentUri
    version?: number
    diagnostics: Diagnostic[]
}

interface CompletionClientCapabilities {
    dynamicRegistration?: boolean
    completionItem?: {
        snippetSupport?: boolean
        commitCharactersSupport?: boolean
        documentationFormat?: MarkupKind[]
        deprecatedSupport?: boolean
        preselectSupport?: boolean
        tagSupport?: {
            valueSet: CompletionItemTag[]
        }

    }
    completionItemKind?: {
        valueSet?: CompletionItemKind[]
    }
    contextSupport?: boolean
}

interface CompletionOptions extends WorkDoneProgressOptions {
    triggerCharacters?: string[]
    allCommitCharacters?: string[]
    resolveProvider?: boolean
}

interface CompletionRegistrationOptions extends TextDocumentRegistrationOptions, CompletionOptions {
}

interface CompletionParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
    context?: CompletionContext
}

namespace CompletionTriggerKind {
    const Invoked: 1 = 1
    const TriggerCharacter: 2 = 2
    const TriggerForIncompleteCompletions: 3 = 3
}

type CompletionTriggerKind = 1 | 2 | 3
    
interface CompletionContext {
    triggerKind: CompletionTriggerKind
    triggerCharacter?: string
}

interface CompletionList {
    isIncomplete: boolean
    items: CompletionItem[]
}

namespace InsertTextFormat {
    const PlainText = 1
    const Snippet = 2
}

type InsertTextFormat = 1 | 2
namespace CompletionItemTag {
    const Deprecated = 1
}

type CompletionItemTag = 1
interface CompletionItem {
    label: string
    kind?: number
    tags?: CompletionItemTag[]
    detail?: string
    documentation?: string | MarkupContent
    deprecated?: boolean
    preselect?: boolean
    sortText?: string
    filterText?: string
    insertText?: string
    insertTextFormat?: InsertTextFormat
    textEdit?: TextEdit
    additionalTextEdits?: TextEdit[]
    commitCharacters?: string[]
    command?: Command
    data?: any
}

namespace CompletionItemKind {
    const Text = 1
    const Method = 2
    const Function = 3
    const constructor = 4
    const Field = 5
    const Variable = 6
    const Class = 7
    const Interface = 8
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
}

interface HoverClientCapabilities {
    dynamicRegistration?: boolean
    contentFormat?: MarkupKind[]
}

interface HoverOptions extends WorkDoneProgressOptions {
}

interface HoverRegistrationOptions extends TextDocumentRegistrationOptions, HoverOptions {
}

interface HoverParams extends TextDocumentPositionParams, WorkDoneProgressParams {
}

interface Hover {
    contents: MarkedString | MarkedString[] | MarkupContent
    range?: Range
}

type MarkedString = string | { language: string , value: string }

interface SignatureHelpClientCapabilities {
    dynamicRegistration?: boolean
    signatureInformation?: {
        documentationFormat?: MarkupKind[]
        parameterInformation?: {
            labelOffsetSupport?: boolean
        }
    }
    contextSupport?: boolean
}

interface SignatureHelpOptions extends WorkDoneProgressOptions {
    triggerCharacters?: string[]
    retriggerCharacters?: string[]
}

interface SignatureHelpRegistrationOptions extends TextDocumentRegistrationOptions, SignatureHelpOptions {
}

interface SignatureHelpParams extends TextDocumentPositionParams, WorkDoneProgressParams {
    context?: SignatureHelpContext
}

namespace SignatureHelpTriggerKind {
    const Invoked: 1 = 1
    const TriggerCharacter: 2 = 2
    const ContentChange: 3 = 3
}

type SignatureHelpTriggerKind = 1 | 2 | 3
interface SignatureHelpContext {
    triggerKind: SignatureHelpTriggerKind
    triggerCharacter?: string
    isRetrigger: boolean
    activeSignatureHelp?: SignatureHelp
}

interface SignatureHelp {
    signatures: SignatureInformation[]
    activeSignature?: number
    activeParameter?: number
}

interface SignatureInformation {
    label: string
    documentation?: string | MarkupContent
    parameters?: ParameterInformation[]
}

interface ParameterInformation {
    label: string | [number, number]
    documentation?: string | MarkupContent
}

interface DeclarationClientCapabilities {
    dynamicRegistration?: boolean
    linkSupport?: boolean
}

interface DeclarationOptions extends WorkDoneProgressOptions {
}

interface DeclarationRegistrationOptions extends DeclarationOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions  {
}

interface DeclarationParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

interface DefinitionClientCapabilities {
    dynamicRegistration?: boolean
    linkSupport?: boolean
}

interface DefinitionOptions extends WorkDoneProgressOptions {
}

interface DefinitionRegistrationOptions extends TextDocumentRegistrationOptions, DefinitionOptions {
}

interface DefinitionParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

interface TypeDefinitionClientCapabilities {
    dynamicRegistration?: boolean
    linkSupport?: boolean
}

interface TypeDefinitionOptions extends WorkDoneProgressOptions {
}

interface TypeDefinitionRegistrationOptions extends TextDocumentRegistrationOptions, TypeDefinitionOptions, StaticRegistrationOptions {
}

interface TypeDefinitionParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

interface ImplementationClientCapabilities {
    dynamicRegistration?: boolean
    linkSupport?: boolean
}

interface ImplementationOptions extends WorkDoneProgressOptions {
}

interface ImplementationRegistrationOptions extends TextDocumentRegistrationOptions, ImplementationOptions, StaticRegistrationOptions {
}

interface ImplementationParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

interface ReferenceClientCapabilities {
    dynamicRegistration?: boolean
}

interface ReferenceOptions extends WorkDoneProgressOptions {
}

interface ReferenceRegistrationOptions extends TextDocumentRegistrationOptions, ReferenceOptions {
}

interface ReferenceParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
    context: ReferenceContext
}

interface ReferenceContext {
    includeDeclaration: boolean
}

interface DocumentHighlightClientCapabilities {
    dynamicRegistration?: boolean
}

interface DocumentHighlightOptions extends WorkDoneProgressOptions {
}

interface DocumentHighlightRegistrationOptions extends TextDocumentRegistrationOptions, DocumentHighlightOptions {
}

interface DocumentHighlightParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

interface DocumentHighlight {
    range: Range
    kind?: number
}

namespace DocumentHighlightKind {
    const Text = 1
    const Read = 2
    const Write = 3
}

interface DocumentSymbolClientCapabilities {
    dynamicRegistration?: boolean
    symbolKind?: {
    valueSet?: SymbolKind[]
}

    hierarchicalDocumentSymbolSupport?: boolean
}

interface DocumentSymbolOptions extends WorkDoneProgressOptions {
}

interface DocumentSymbolRegistrationOptions extends TextDocumentRegistrationOptions, DocumentSymbolOptions {
}

interface DocumentSymbolParams extends WorkDoneProgressParams, PartialResultParams {
    textDocument: TextDocumentIdentifier
}

namespace SymbolKind {
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
        const Interface = 11
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
}

interface DocumentSymbol {
    name: string
    detail?: string
    kind: SymbolKind
    deprecated?: boolean
    range: Range
    selectionRange: Range
    children?: DocumentSymbol[]
}

interface SymbolInformation {
    name: string
    kind: SymbolKind
    deprecated?: boolean
    location: Location
    containerName?: string
}

interface CodeActionClientCapabilities {
    dynamicRegistration?: boolean
    codeActionLiteralSupport?: {
    codeActionKind: {
    valueSet: CodeActionKind[]
}

}

    isPreferredSupport?: boolean
}

interface CodeActionOptions extends WorkDoneProgressOptions {
    codeActionKinds?: CodeActionKind[]
}

interface CodeActionRegistrationOptions extends TextDocumentRegistrationOptions, CodeActionOptions {
}

interface CodeActionParams extends WorkDoneProgressParams, PartialResultParams {
    textDocument: TextDocumentIdentifier
    range: Range
    context: CodeActionContext
}

type CodeActionKind = string
namespace CodeActionKind {
    const Empty: CodeActionKind = ''
    const QuickFix: CodeActionKind = 'quickfix'
    const Refactor: CodeActionKind = 'refactor'
    const RefactorExtract: CodeActionKind = 'refactor.extract'
    const RefactorInline: CodeActionKind = 'refactor.inline'
    const RefactorRewrite: CodeActionKind = 'refactor.rewrite'
    const Source: CodeActionKind = 'source'
    const SourceOrganizeImports: CodeActionKind = 'source.organizeImports'
}

interface CodeActionContext {
    diagnostics: Diagnostic[]
    only?: CodeActionKind[]
}

interface CodeAction {
    title: string
    kind?: CodeActionKind
    diagnostics?: Diagnostic[]
    isPreferred?: boolean
    edit?: WorkspaceEdit
    command?: Command
}

interface CodeLensClientCapabilities {
    dynamicRegistration?: boolean
}

interface CodeLensOptions extends WorkDoneProgressOptions {
    resolveProvider?: boolean
}

interface CodeLensRegistrationOptions extends TextDocumentRegistrationOptions, CodeLensOptions {
}

interface CodeLensParams extends WorkDoneProgressParams, PartialResultParams {
    textDocument: TextDocumentIdentifier
}

interface CodeLens {
    range: Range
    command?: Command
    data?: any
}

interface DocumentLinkClientCapabilities {
    dynamicRegistration?: boolean
    tooltipSupport?: boolean
}

interface DocumentLinkOptions extends WorkDoneProgressOptions {
    resolveProvider?: boolean
}

interface DocumentLinkRegistrationOptions extends TextDocumentRegistrationOptions, DocumentLinkOptions {
}

interface DocumentLinkParams extends WorkDoneProgressParams, PartialResultParams {
    textDocument: TextDocumentIdentifier
}

interface DocumentLink {
    range: Range
    target?: DocumentUri
    tooltip?: string
    data?: any
}

interface DocumentColorClientCapabilities {
    dynamicRegistration?: boolean
}

interface DocumentColorOptions extends WorkDoneProgressOptions {
}

interface DocumentColorRegistrationOptions extends TextDocumentRegistrationOptions, StaticRegistrationOptions, DocumentColorOptions {
}

interface DocumentColorParams extends WorkDoneProgressParams, PartialResultParams {
    textDocument: TextDocumentIdentifier
}

interface ColorInformation {
    range: Range
    color: Color
}

interface Color {
    readonly red: number
    readonly green: number
    readonly blue: number
    readonly alpha: number
}

interface ColorPresentationParams extends WorkDoneProgressParams, PartialResultParams {
    textDocument: TextDocumentIdentifier
    color: Color
    range: Range
}

interface ColorPresentation {
    label: string
    textEdit?: TextEdit
    additionalTextEdits?: TextEdit[]
}

interface DocumentFormattingClientCapabilities {
    dynamicRegistration?: boolean
}

interface DocumentFormattingOptions extends WorkDoneProgressOptions {
}

interface DocumentFormattingRegistrationOptions extends TextDocumentRegistrationOptions, DocumentFormattingOptions {
}

interface DocumentFormattingParams extends WorkDoneProgressParams {
    textDocument: TextDocumentIdentifier
    options: FormattingOptions
}

interface FormattingOptions {
    tabSize: number
    insertSpaces: boolean
    trimTrailingWhitespace?: boolean
    insertFinalNewline?: boolean
    trimFinalNewlines?: boolean
    [key: string]: boolean | number | string
}

interface DocumentRangeFormattingClientCapabilities {
    dynamicRegistration?: boolean
}

interface DocumentRangeFormattingOptions extends WorkDoneProgressOptions {
}

interface DocumentRangeFormattingRegistrationOptions extends TextDocumentRegistrationOptions, DocumentRangeFormattingOptions {
}

interface DocumentRangeFormattingParams extends WorkDoneProgressParams {
    textDocument: TextDocumentIdentifier
    range: Range
    options: FormattingOptions
}

interface DocumentOnTypeFormattingClientCapabilities {
    dynamicRegistration?: boolean
}

interface DocumentOnTypeFormattingOptions {
    firstTriggerCharacter: string
    moreTriggerCharacter?: string[]
}

interface DocumentOnTypeFormattingRegistrationOptions extends TextDocumentRegistrationOptions, DocumentOnTypeFormattingOptions {
}

interface DocumentOnTypeFormattingParams extends TextDocumentPositionParams {
    ch: string
    options: FormattingOptions
}

interface RenameClientCapabilities {
    dynamicRegistration?: boolean
    prepareSupport?: boolean
}

interface RenameOptions extends WorkDoneProgressOptions {
    prepareProvider?: boolean
}

interface RenameRegistrationOptions extends TextDocumentRegistrationOptions, RenameOptions {
}

interface RenameParams extends TextDocumentPositionParams, WorkDoneProgressParams {
    newName: string
}

interface PrepareRenameParams extends TextDocumentPositionParams {
}

interface FoldingRangeClientCapabilities {
    dynamicRegistration?: boolean
    rangeLimit?: number
    lineFoldingOnly?: boolean
}

interface FoldingRangeOptions extends WorkDoneProgressOptions {
}

interface FoldingRangeRegistrationOptions extends TextDocumentRegistrationOptions, FoldingRangeOptions, StaticRegistrationOptions {
}

interface FoldingRangeParams extends WorkDoneProgressParams, PartialResultParams {
    textDocument: TextDocumentIdentifier
}

enum FoldingRangeKind {
    Comment = 'comment',
    Imports = 'imports',
    Region = 'region'
}

interface FoldingRange {
    startLine: number
    startCharacter?: number
    endLine: number
    endCharacter?: number
    kind?: string
}

interface SelectionRangeClientCapabilities {
    dynamicRegistration?: boolean
}

interface SelectionRangeOptions extends WorkDoneProgressOptions {
}

interface SelectionRangeRegistrationOptions extends SelectionRangeOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions {
}

interface SelectionRangeParams extends WorkDoneProgressParams, PartialResultParams {
    textDocument: TextDocumentIdentifier
    positions: Position[]
}

interface SelectionRange {
    range: Range
    parent?: SelectionRange
}
   