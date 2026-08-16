if command -v zoxide &>/dev/null; then
	export _ZO_ECHO=1 # 移動先ディレクトリを出力
    eval "$(zoxide init zsh)"
fi
