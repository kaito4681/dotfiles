if [[ -o interactive && -t 0 ]]; then
    { stty -ixon < /dev/tty } 2>/dev/null
fi

# Open paths in the local VS Code through WezTerm (see README).
if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" ]]; then
    function code() {
        emulate -L zsh
        zmodload -F zsh/datetime p:EPOCHREALTIME
        if [[ -n "$VSCODE_IPC_HOOK_CLI" ]]; then
            command code "$@"
            return $?
        fi

        local remote_host="${WEZTERM_VSCODE_SSH_HOST:-}"
        if [[ "$remote_host" == -* || "$remote_host" == *[^a-zA-Z0-9_.@:+-]* ]]; then
            print -u2 'code: invalid WEZTERM_VSCODE_SSH_HOST'
            return 1
        fi
        if (( $# > 1 )) || [[ "${1:-.}" == -* ]]; then
            print -u2 'Usage: code [file-or-directory] (WezTerm remote bridge)'
            return 1
        fi
        local target="${1:-.}"
        target="${target:a}"
        if [[ "$target" == *$'\t'* || "$target" == *$'\r'* || "$target" == *$'\n'* ]]; then
            print -u2 'code: paths containing tabs or newlines are unsupported'
            return 1
        fi
        local id="${EPOCHREALTIME//./}$RANDOM"
        local payload
        payload=$(printf '%s\t%s\t%s' "$id" "$remote_host" "$target" | base64 | tr -d '\r\n') || return 1
        # Send copies for 0, 1 and 2 tmux layers (needs allow-passthrough).
        local esc=$'\e'
        local sequence="$esc]1337;SetUserVar=OPEN_VSCODE=$payload"$'\a'
        local once="${esc}Ptmux;${sequence//$esc/$esc$esc}$esc\\"
        local twice="${esc}Ptmux;${once//$esc/$esc$esc}$esc\\"
        printf '%s' "$sequence" "$once" "$twice"
    }
fi
