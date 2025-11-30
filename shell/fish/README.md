# fish shell

# installation

```bash
brew install fish fisher
fisher update
```

## plugins

* `jethrokuan/fzf`: ファイル検索機能
	
	※ optionキーをメタキーとして使用するようにターミナルアプリで設定する．

	| 機能 | keybind | 説明 |
	| :--- | :--- | :--- |
	| **コマンド履歴検索** | `Ctrl+r` | 過去に入力したコマンドを検索して呼び出します。 |
	| **ファイル検索** | `Ctrl+o` | カレントディレクトリ以下のファイルを検索します。 |
	| **ディレクトリ移動** | `Alt+c` | サブディレクトリを検索し、選択した場所へ`cd`（移動）します。 |
	| **全検索移動** | `Alt+Shift+c` | 隠しディレクトリを含むすべてのサブディレクトリを検索して移動します。 |
	| **ファイルを開く** | `Alt+o` | 検索したファイルをデフォルトのエディタ（`$EDITOR`）で開きます。 |
	| **外部で開く** | `Alt+Shift+o` | 検索したファイルやディレクトリをシステムのデフォルトアプリ（`open`や`xdg-open`）で開きます。 |

	

* `decors/fish-ghq`: 
* `0rax/fish-bd`: `bd`で任意の親ディレクトリに戻る．
* `ryoppippi/bdf.fish`: `bd`で任意の親ディレクトリに戻る．(十字キーで選択)