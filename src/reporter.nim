import strformat

const
    ansiReset = "\e[0m"
    ansiBold  = "\e[1m"

const shouldLog = false

type
    LogLevel = enum
        FAIL = ansiBold & "\e[31mFAIL\e[0m " & ansiReset
        WARN = ansiBold & "\e[33mWARN\e[0m " & ansiReset
        INFO = ansiBold & "\e[36mINFO\e[0m " & ansiReset

    Spot = ((int, int), (int, int))

    ReportElement* = tuple
        lvl  : LogLevel
        spot : Spot
        txt  : string

    Report* = seq[ReportElement]

#

converter toInt*(lv: LogLevel): int =
    case lv :
    of FAIL :  0
    of WARN :  1
    of INFO :  2

proc link(spot: Spot): string =
    let file = "./test.gth"
    let line = spot[0][0] + 1
    let colm = spot[0][1] + 1
    return &"{ansiBold}{file}({line}, {colm}){ansiReset} "

# 

var reporter = newSeq[Report]()

proc record*() =  
    reporter.add( newSeq[ReportElement]() )

proc report*(): Report =
    return reporter.pop()

#

proc fail*(spot: Spot, txt: string) = 
    reporter[^1].add( (FAIL, spot, txt) )

    if shouldLog : echo FAIL, link(spot), txt

proc warn*(spot: Spot, txt: string) =
    reporter[^1].add( (WARN, spot, txt) )

    if shouldLog : echo FAIL, link(spot), txt

proc info*(spot: Spot, txt: string) =
    reporter[^1].add( (INFO, spot, txt) )

    if shouldLog : echo FAIL, link(spot), txt