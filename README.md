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
使用する際は，`.chezmoidata/github.toml`の`username`を変更してください．
このgithubアカウントを使って以下が設定されます．
- git config user.name <github username>
- git config user.email <github private email>
- `~/.ssh/authorized_keys`

## reference

- private email: 
  - 確認URL:	`https://github.com/settings/emails`
  - 取得URL:	`https://api.github.com/users/<username>`
- ssh key: 
  - 設定URL: `https://github.com/settings/keys`
  - 取得URL: `https://github.com/<username>.keys`
