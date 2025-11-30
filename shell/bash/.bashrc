# ~/.bashrc

export LANG=en_US.UTF-8
export BASH_SILENCE_DEPRECATION_WARNING=1

# --- シェルの判定 ---
if [ -n "$ZSH_VERSION" ]; then
    MY_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
    MY_SHELL="bash"
else
    exit
fi

# local bin
export PATH=":$HOME/.local/bin:$PATH"

# brew
eval $(/opt/homebrew/bin/brew shellenv)

# mise
eval "$(mise activate $MY_SHELL)"
export PATH="$HOME/.local/share/mise/shims:$PATH"

# rust
export PATH="$HOME/.cargo/bin:$PATH"
source "$HOME/.cargo/env"

# tex
export PATH="/Library/TeX/texbin:$PATH"

# bun
export PATH="/Users/kaito/.bun/bin:$PATH"

# uv (python)
eval "$(uv generate-shell-completion $MY_SHELL)"

# texlive
eval "$(/usr/libexec/path_helper)"

# LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

# Google Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# tailscale
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# draw.io
alias draw.io="/Applications/draw.io.app/Contents/MacOS/draw.io"

# Docker CLI completions
fpath=(/Users/kaito/.docker/completions $fpath)

# ls
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'

# git
alias g='git'
alias gp='git pull'
alias gc='git commit'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gci="mkdir -p .github;touch .github/copilot-instructions.md"

# bun
alias b="bun"
alias bd='bun dev'
alias bb='bun run build'
alias bs='bun start'
alias bbs='bun run build;bun start'

# sudoでvscode
alias sudocode='SUDO_EDITOR="$(which code) --wait" sudoedit'
alias scode='SUDO_EDITOR="$(which code) --wait" sudoedit'

# starship
eval "$(starship init $MY_SHELL)"