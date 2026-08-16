function chezmoi() {
    if [[ "$#" -eq 1 && "$1" == "cd" ]]; then
        builtin cd -- "$(command chezmoi source-path)"
    else
        command chezmoi "$@"
    fi
}
