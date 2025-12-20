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

### 3. その他のインストール

```bash
mise install
sheldon lock
```

