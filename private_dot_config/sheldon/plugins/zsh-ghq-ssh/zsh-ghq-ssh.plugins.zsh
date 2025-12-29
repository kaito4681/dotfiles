# ghq-ssh.plugin.zsh - Search ghq repositories (local and remote) with fzf

# Store script path at source time for reload to work
__GHQ_SSH_PLUGIN_PATH="${0:A}"

# Search local ghq repositories
__ghq_search_local() {
    ghq list --full-path | sed 's|^|local:|'
}

# Search remote ghq repositories
__ghq_search_remote() {
    if [[ -z "${GHQ_REMOTE_HOSTS}" ]]; then
        echo "error:GHQ_REMOTE_HOSTS_not_set"
        return
    fi

    local pids=()
    for host in ${(s: :)GHQ_REMOTE_HOSTS}; do
        local ghq_path="ghq"
        local var_name="GHQ_PATH_${host}"
        if [[ -n "${(P)var_name}" ]]; then
            ghq_path="${(P)var_name}"
        fi
        ssh -q "$host" "$ghq_path list --full-path" 2>/dev/null | sed "s|^|remote:$host:|" &
        pids+=($!)
    done
    wait "${pids[@]}" 2>/dev/null
}

# Main search function
__ghq_search() {
    local to_local="change-prompt([Local] > )+change-header(CTRL+R: to Remote SSH	| alt+ENTER: Open in VSCode)+reload(zsh -c 'source $__GHQ_SSH_PLUGIN_PATH; __ghq_search_local')"
    local to_remote="change-prompt([Remote] > )+change-header(CTRL+R: to Local	| alt+ENTER: Open in VSCode)+reload(zsh -c 'source $__GHQ_SSH_PLUGIN_PATH; __ghq_search_remote')"

    local toggle_cmd="transform:echo {fzf:prompt} | grep -q 'Local' && echo \"$to_remote\" || echo \"$to_local\""

    local fzf_out
    fzf_out=$(__ghq_search_local | fzf \
        --ansi \
        --delimiter : \
        --with-nth 2.. \
        --prompt="[Local] > " \
        --header="ctrl+R: to Remote SSH	| alt+ENTER: Open in VSCode" \
        --expect=alt-enter \
        --bind "ctrl-r:$toggle_cmd"
    )

    if [[ -z "$fzf_out" ]]; then
        zle reset-prompt 2>/dev/null
        return
    fi

    # Process the results
    local key_pressed=""
    local result=""

    local lines=("${(f)fzf_out}")
    if [[ ${#lines[@]} -eq 2 ]]; then
        key_pressed="${lines[1]}"
        result="${lines[2]}"
    else
        result="${lines[1]}"
    fi

    local type="${result%%:*}"

    if [[ "$type" == "local" ]]; then
        local path="${result#*:}"
        
        if [[ "$key_pressed" == "alt-enter" ]]; then
            # vscode
            code -n "$path"
        else
            # cd
            cd "$path"
        fi
    
    elif [[ "$type" == "remote" ]]; then
        local rest="${result#remote:}"
        local host="${rest%%:*}"
        local path="${rest#*:}"
        
        if [[ "$key_pressed" == "alt-enter" ]]; then
            # vscode remote
            echo "Opening in VS Code Remote..."
            code --folder-uri "vscode-remote://ssh-remote+$host$path"
        else
            # ssh
            echo "Connecting to $host..."
            ssh -t "$host" "cd '$path' && exec \$SHELL -l"
        fi
        
    elif [[ "$type" == "error" ]]; then
        echo "Error: GHQ_REMOTE_HOSTS is not set."
    fi

    zle reset-prompt 2>/dev/null
}

# Widget wrapper for zle
__ghq_search_widget() {
    BUFFER=""
    __ghq_search
    zle accept-line
}

# Register widget and bind to Ctrl+G
zle -N __ghq_search_widget
bindkey '^g' __ghq_search_widget
