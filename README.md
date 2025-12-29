# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## セットアップ (Setup)

### 1. miseのインストール

```bash
curl https://mise.run | sh
```


### 2. chezmoiの適用

```bash
~/.local/bin/mise x chezmoi@latest -- chezmoi init --apply kaito4681
```

gitのuser名を変更するには，`.chezmoidata/github.toml`の`username`を変更する．
emailは，githubのprivateメールアドレスが自動で設定される．

