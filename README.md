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

初回実行時に `Configure Git/GitHub account settings` と確認されます。
`true`（既定値）を選ぶと、続けて入力した GitHub ユーザー名を使って以下が設定されます。

- git config user.name <github username>
- git config user.email <github private email>
- GitHub の credential helper
- `~/.ssh/authorized_keys`

`false` を選ぶと、GitHub ユーザー名の入力を省略し、上記のアカウント関連設定を chezmoi で管理しません。Git の LFS、既定ブランチ、エイリアスなどの一般設定は引き続き適用されます。

## reference

- private email: 
  - 確認URL:	`https://github.com/settings/emails`
  - 取得URL:	`https://api.github.com/users/<username>`
- ssh key: 
  - 設定URL: `https://github.com/settings/keys`
  - 取得URL: `https://github.com/<username>.keys`
