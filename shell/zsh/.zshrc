# ~/.zshrc

# comp 初期化
autoload -Uz compinit
compinit

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi


# zinit
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
(( ${+_comps} )) && _comps[zinit]=_zinit # zinit 補完が効かないときだけ有効化


# zsh-users/zsh-autosuggestions
# コマンド履歴から入力候補を表示
zinit wait lucid for \
    atload'!_zsh_autosuggest_start' \
    zsh-users/zsh-autosuggestions

# zsh-users/zsh-completions
# Tab補完の強化
zinit wait lucid for \
    blockf \
    zsh-users/zsh-completions

# zsh-users/zsh-syntax-highlighting
# コマンドの有効/無効を色分け表示します（一番最後に読み込む必要あり）
zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zsh-users/zsh-syntax-highlighting


# zsh-users/zsh-history-substring-search
# 入力途中のコマンドに一致する履歴を矢印キーで検索します
zinit wait lucid for \
    atload'bindkey "^[[A" history-substring-search-up; bindkey "^[[B" history-substring-search-down' \
    zsh-users/zsh-history-substring-search

# aliasを使わなかったときに提案
zinit light MichaelAquilina/zsh-you-should-use

