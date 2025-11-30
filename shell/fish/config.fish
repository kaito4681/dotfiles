set -gx LANG "en_US.UTF-8"

# disable the welcome message
set fish_greeting

# define XDG paths
set -q XDG_CONFIG_HOME || set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME || set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_CACHE_HOME || set -gx XDG_CACHE_HOME $HOME/.cache

# define fish config paths
set -g FISH_CONFIG_DIR $XDG_CONFIG_HOME/fish
set -g FISH_CONFIG $FISH_CONFIG_DIR/config.fish
set -g FISH_CACHE_DIR /tmp/fish-cache

# brew
fish_add_path /opt/homebrew/bin

# general bin paths
fish_add_path $HOME/.local/bin

# bun
fish_add_path $HOME/.bun/bin

# rust
fish_add_path $HOME/.cargo/bin

# mise
fish_add_path $HOME/.local/share/mise/shims

# tex
fish_add_path /Library/TeX/texbin

# google antigravity
fish_add_path $HOME/.antigravity/antigravity/bin

# tailscale
abbr tailscale '/Applications/Tailscale.app/Contents/MacOS/Tailscale'

# draw.io
abbr draw.io '/Applications/draw.io.app/Contents/MacOS/draw.io'

# LM Studio CLI (lms)
fish_add_path $HOME/.lmstudio/bin


# starship theme
starship init fish | source

