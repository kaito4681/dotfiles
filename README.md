# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## セットアップ (Setup)

### 1. chezmoi のインストール

詳細なインストール方法は [chezmoi.io](https://www.chezmoi.io/install/) を参照してください。

**macOS (Homebrew):**
```bash
brew install chezmoi
```

**One-line install (curl):**
```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 2. 初期化と適用 (Initialize & Apply)

このリポジトリを初期化し、設定を適用します。

```bash
chezmoi init --apply kaito4681
```

## よく使うコマンド (Usage)

- **設定ファイルの編集:**
  ```bash
  chezmoi edit ~/.zshrc
  ```
  編集完了後、エディタを閉じると自動的に `chezmoi apply` を実行するか尋ねられます（設定による）。手動で適用する場合は `chezmoi apply` を実行します。

- **変更の適用:**
  ```bash
  chezmoi apply
  ```

- **ファイルの追加:**
  ```bash
  chezmoi add <ファイル名>
  ```

- **変更点（Diff）の確認:**
  ```bash
  chezmoi diff
  ```

- **リポジトリの更新（Pull & Apply）:**
  ```bash
  chezmoi update
  ```