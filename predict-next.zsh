function predict_next() {
    nexts_str=$(history |
                grep -A1 "$BUFFER" |
                grep -v "$BUFFER" |
                cut -b 8-)

    # split by new line
    nexts_arr=("${(f)nexts_str}")

    typeset -A dict
    typeset -A best
    best["occ"]=0

    for next in ${nexts_arr[*]}; do
        # init or increase the counter
        $(test $dict[$next]) && dict[$next]=$((dict[$next]+1)) || dict[$next]=1

        # collect best to prevent additional loop
        $(test $dict[$next] -gt $best["occ"]) && best["occ"]=$dict[$next] && best["cmd"]=$next
    done

    POSTDISPLAY=" && $best["cmd"]"
}


zle -N predict_next
bindkey '^ ' predict_next

ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(predict_next)

