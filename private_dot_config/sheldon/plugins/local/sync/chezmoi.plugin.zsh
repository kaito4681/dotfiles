function chezmoi() {
    if [[ "$#" -eq 1 && "$1" == "cd" ]]; then
        builtin cd -- "$(command chezmoi source-path)"
    else
        # gitHubKeys などが API のレート制限に掛からないよう gh のトークンを渡す
        local token="${CHEZMOI_GITHUB_ACCESS_TOKEN:-}"
        if [[ -z "$token" ]] && (( $+commands[gh] )); then
            token="$(gh auth token 2>/dev/null)"
        fi
        CHEZMOI_GITHUB_ACCESS_TOKEN="$token" command chezmoi "$@"
    fi
}
