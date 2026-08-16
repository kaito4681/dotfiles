autoload -Uz compinit

: "${XDG_CACHE_HOME:=$HOME/.cache}"
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
[[ -d "${ZSH_COMPDUMP:h}" ]] || mkdir -p "${ZSH_COMPDUMP:h}"

if [[ -s "$ZSH_COMPDUMP" ]]; then
    compinit -C -d "$ZSH_COMPDUMP"
else
    compinit -d "$ZSH_COMPDUMP"
fi

for c in "${__compdef_queue[@]}"; do
    [[ -n "$c" ]] || continue
    compdef ${=c}
done
unset __compdef_queue
