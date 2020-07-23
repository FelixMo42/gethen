const
    failLabel = "\e[31mFAIL\e[0m "
    warnLabel = "\e[33mWARN\e[0m "
    infoLabel = "\e[36mINFO\e[0m "

proc fail*(txt: string) = 
    echo failLabel, txt

proc warn*(txt: string) =
    echo warnLabel, txt

proc info*(txt: string) =
    echo infoLabel, txt

# fail "123"
# warn "456"
# info "789"