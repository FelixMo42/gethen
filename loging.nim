import os
import strutils

const storage = currentSourcePath().parentDir / "tmp"

let logFile = open(storage / "lsp.log", fmWrite)

type logLevel* = enum
    ERROR,
    WARN,
    INFO,
    DEBUG

proc log(msg: string) =
    logFile.write(msg)
    logFile.write("\n")
    logFile.flushFile()

proc logError(msg: string) = 
    log("ERROR " & msg)

proc logWarn(msg: string) =
    log("WARN " & msg)

proc logInfo(msg: string) = 
    log("INFO " & msg)

proc logDebug(msg: string) =
    log("DEBUG " & msg)

proc log*(args: varargs[string, `$`]) =
    logInfo(join args)

proc log*(level: logLevel, args: varargs[string, `$`]) =
    if level == ERROR : logError(join args)
    if level == WARN  : logWarn(join args)
    if level == INFO  : logInfo(join args)
    if level == DEBUG : logDebug(join args)