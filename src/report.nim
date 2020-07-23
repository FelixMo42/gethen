import strformat

const
    ansiReset = "\e[0m"
    ansiBold = "\e[1m"

type
    LogLevel = enum
        FAIL = ansiBold & "\e[31mFAIL\e[0m " & ansiReset
        WARN = ansiBold & "\e[33mWARN\e[0m " & ansiReset
        INFO = ansiBold & "\e[36mINFO\e[0m " & ansiReset

    Spot = ((int, int), (int, int))

proc link(spot: Spot): string =
    # let file = "~/Documents/gethen/src/test.txt"
    let file = "./test.txt"
    let line = spot[0][0] + 1
    let colm = spot[0][1] + 1
    return &"{ansiBold}{file}({line}, {colm}){ansiReset} "

proc fail*(spot: Spot, txt: string) = 
    # echo link(spot)
    echo FAIL, link(spot), txt

proc warn*(spot: Spot, txt: string) =
    echo WARN, txt

proc info*(spot: Spot, txt: string) =
    echo INFO, txt

# fail "123"
# warn "456"
# info "789"