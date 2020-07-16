import streams
import strutils
import parseutils
import json

type
    BaseProtocolError* = object of ValueError
    MalformedFrame* = object of BaseProtocolError
    UnsupportedEncoding* = object of BaseProtocolError

proc skipWhitespace(x: string, pos: int): int =
    result = pos
    while result < x.len and x[result] in Whitespace:
        inc result

proc sendFrame*(s: Stream, frame: string) =
    s.write "Content-Length: " & $frame.len & "\r\n\r\n" & frame
    s.flush()

proc readFrame*(s: Stream): TaintedString =
    var contentLen = -1
    var headerStarted = false

    while true:
        var ln = string s.readLine()

        if ln.len != 0:
            headerStarted = true
            let sep = ln.find(':')
            if sep == -1:
                raise newException(MalformedFrame, "invalid header line: " & ln)

            let valueStart = ln.skipWhitespace(sep + 1)

            case ln[0 ..< sep]
                of "Content-Type":
                    if ln.find("utf-8", valueStart) == -1 and ln.find("utf8", valueStart) == -1:
                        raise newException(UnsupportedEncoding, "only utf-8 is supported")
                of "Content-Length":
                    if parseInt(ln, contentLen, valueStart) == 0:
                        raise newException(MalformedFrame, "invalid Content-Length: " & ln.substr(valueStart))
                else:
                    discard
        elif not headerStarted:
            continue
        else:
            if contentLen != -1:
                return s.readStr(contentLen)
            else:
                raise newException(MalformedFrame, "missing Content-Length header")

proc sendJson*(s: Stream, data: JsonNode) =
    var frame = newStringOfCap(1024)
    toUgly(frame, data)
    s.sendFrame(frame)

proc readJson*(s: Stream): JsonNode = 
    return s.readFrame().parseJson()