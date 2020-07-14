import os
import strutils

const storage = currentSourcePath().parentDir / "tmp"

let logFile = open(storage / "lsp.log", fmWrite)

type logLevel* = enum Error, Warn, Info, Debug

proc log*(args: varargs[string, `$`]) =
    logFile.write("[info] ")
    logFile.write(join args)
    logFile.write("\n\n")
    logFile.flushFile()