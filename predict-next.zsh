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

    typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT="$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
    region_highlight+=("$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT")

    zle -R
    zle read-command

    $(test "$REPLY" '==' "forward-char") && BUFFER=$BUFFER$POSTDISPLAY;

    CURSOR=${#BUFFER}
    unset POSTDISPLAY
    unset region_highlight
}


ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(predict_next)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=blue'


zle -N predict_next
bindkey '^ ' predict_next
