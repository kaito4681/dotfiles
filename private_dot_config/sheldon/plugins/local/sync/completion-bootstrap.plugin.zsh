# compinitより先に呼ばれたcompdefはキューへ保存する。
typeset -ga __compdef_queue
function compdef() {
    __compdef_queue+=("$*")
}

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:messages' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %d%f'
zstyle ':completion:*' group-name ''
