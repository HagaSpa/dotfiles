# Raycast の dotfiles 管理 検討結果 (2026-05)

Raycast のホットキー/エイリアスを dotfiles リポジトリで管理する方法を検討した結果。**結論: 当面 dotfiles 化はしない。Raycast 上で手動管理を継続する。**

## 背景

- Raycast でアプリ起動ホットキー（⌥⇧C → Cursor 等）と Aliases (`f` → Finder 等) を多用
- Karabiner / zsh / ghostty などと同様に、設定の現物を GitHub で履歴管理したい動機
- 既存 dotfiles は `link.sh` による symlink 方式

## 結論

| アプローチ | 採用可否 |
|---|---|
| `.rayconfig` 全体を commit（暗号化バイナリ） | ❌ diff が読めず履歴の意味が薄い |
| `.rayconfig` 復号 → JSON 部分抽出 | ❌ 部分 JSON の import が公式未対応、再暗号化スクリプト必要 |
| Quicklinks / Snippets のみ専用 export | ❌ 主用途の Hotkey/Alias がカバーされない |
| Markdown で宣言的に管理（手動再設定） | △ 機密リスクゼロだが Hotkey/Alias 数が多く現実的でない |
| Raycast CLI / `raycast://` URL scheme | ❌ コマンド発火用 API のみ、設定書き換え不可 |
| SQLite 直接書き換え | ❌ schema 非公開、Raycast 起動中は書けない、アップデートで破綻 |
| Karabiner 完全移行 | ❌ 一部ホットキーで「2 回目押下で hide」トグル動作を多用しており非互換 |

## 各アプローチが不採用な理由

### `.rayconfig` ベース運用

- 形式: gzip + AES-256-CBC、パスフレーズ必須
- 暗号化のままでは diff が機能しない
- 復号して JSON にしても、Raycast 公式 Import は完全な `.rayconfig` を要求するため、新マシンで戻すには再暗号化スクリプトが必要
- 拡張機能の preference（API トークン等）も同じ JSON に同居するため、将来 GitHub 拡張等を入れた際の機密混入リスクが残る

### 専用 export (Quicklinks / Snippets) のみ

Raycast には `Export Quicklinks` / `Export Snippets` という個別エクスポートコマンドがあり plain JSON で出せるが、**主用途であるアプリ起動 Hotkey と Aliases は対象外**。これらだけ管理しても価値が薄い。

### CLI / `raycast://` URL scheme

- Raycast は公式 CLI を提供していない
- `raycast://` URL scheme は **コマンドを発火する用途**（例: `raycast://extensions/raycast/clipboard-history/clipboard-history`）であり、ホットキー割り当てを書き換える API は存在しない

### SQLite 直叩き

技術的には `~/Library/Application Support/com.raycast.macos/` 配下の DB を書き換える発想は可能。ただし以下の理由で運用コストが価値を上回る:

1. **schema 非公開**: テーブル/カラムをリバースエンジニアリングする必要がある
2. **アプリ稼働中は書けない**: Raycast は in-memory 状態を終了時に flush するため、起動中の DB 書き換えは上書きされる。毎回 quit → write → 再起動が必要
3. **アップデート耐性ゼロ**: Raycast のマイナーバージョン更新で schema が変わると壊れる。Karabiner JSON のように仕様が公開されていない以上、追従コストが永続化
4. **失敗時の影響大**: 書き間違い 1 回で全設定喪失リスク

Karabiner（JSON 形式が完全ドキュメント化）と異なり、**Raycast は本質的に閉じた設定**である。

### Karabiner への移管

アプリ起動ホットキーは Karabiner の `shell_command` (`open -a` または `osascript ... activate`) で代替可能で、技術的には JSON 化できる。ただし以下の非互換が判明:

- **トグル hide 動作**: Raycast はホットキーで「フォアグラウンド時にもう一度押すと隠す」挙動を持ち、ユーザーがこれを多用している
- Karabiner + `open -a` ではこの動作は再現されない（再アクティブ化のみ）
- 自前で `if frontmost? then hide else activate` を AppleScript で組むことは可能だが、複数アプリ分実装する手間とメンテコストに見合わない

その他の微差（shell fork のレイテンシ、Stage Manager / 複数 Space での window 引き寄せロジック）は実用上問題にならないと判断。

## 学び

- **設定の dotfiles 化は「公式に export/import 形式が公開されている」ことが前提**。Raycast のように暗号化バイナリ単一形式しか公式提供がないアプリは、無理に管理しようとすると独自スクリプトの保守負債になる
- **CLI や DB 直叩きは "やれそう" と見えても、schema 非公開・アップデート追従・稼働中ロックで現実コストが膨らむ**。Karabiner のような JSON 公開仕様の対極にある
- **同一機能でも代替ツール間で挙動が完全一致するとは限らない**。今回はトグル hide の有無が決定打になった。移行検討時は「自分が常用している副次動作」も含めて差分を洗うこと

## 関連

- `.config/karabiner/` — キーリマップは引き続き Karabiner で JSON 管理
- [Karabiner vs Nix 検討結果](karabiner-vs-nix.md) — 同様に「移行コストが ROI に見合わず見送り」となった検討
