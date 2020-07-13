import os
import strutils
import terminal
# import cfg

const storage = currentSourcePath().parentDir / "tmp"

let logFile = open(storage / "lsp.log", fmWrite)

type logLevel* = enum Error, Warn, Info, Debug

proc log*(args: varargs[string, `$`]) =
    stderr.styledWrite(fgBlue, "[info] ")
    stderr.styledWrite(join args)
    stderr.styledWrite("\n")
    
    logFile.write(join args)
    logFile.write("\n\n")
    logFile.flushFile()