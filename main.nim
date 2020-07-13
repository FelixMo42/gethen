import streams
import loging
import os
import jsonstream

const version = "0.0.0"
const storage = currentSourcePath().parentDir / "tmp"

let ins  = newFileStream(stdin)
let outs = newFileStream(stdout)


# make sure that a tmp folder exist
discard existsOrCreateDir(storage)

template whenValid(data, kind, body) =
    if data.isValid(kind, allowExtra = true):
        var data = kind(data)
        body
    else:
        debugEcho("Unable to parse data as " & $kind)

log "version: " & version

while true:
    try:
        let message = ins.readJson()
    
        whenValid(message, ):

    except IOError:
        break
    except CatchableError as e:
        log "Got exception: ", e.msg