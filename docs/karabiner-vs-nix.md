# Karabiner vs Nix 検討結果 (2026-04)

このリポジトリの OS レベル設定（Karabiner Elements + `settings.sh`）を Nix に置き換えられるかを検討した結果。**結論: 当面 Nix を導入する必要はない。**

## 背景

- macOS 設定は `settings.sh` の `defaults write` 3 項目のみ
- キーリマップは Karabiner Elements の complex_modifications で管理
- 「パッケージマネージャとしての Nix は使わず、OS 操作・設定だけ Nix に委譲」できないかを検討

## 結論

| 対象 | Nix で代替可能か |
|---|---|
| Karabiner Elements 本体 | ❌ 不可 |
| `settings.sh` の `defaults write` | ✅ 可（`system.defaults.*`） |
| キー remap を Karabiner なしで実現 | ❌ hidutil では機能不足 |

## Karabiner が Nix で代替不可な理由

Karabiner は macOS のシステム拡張（System Extension／旧 kext）を使って **HID イベントをカーネルレベルで横取り** することでキー remap を実現している。Nix／nix-darwin はあくまで宣言的な設定・パッケージ管理ツールであり、それ自体に HID イベント横取り機能はない。

nix-darwin には `services.karabiner-elements` モジュールがあるが、これは Karabiner を Nix 経由でインストール・設定するもので、Karabiner を不要にするものではない。

## hidutil で代替できないルール一覧

`personal_hagaspa.json` の 7 ルールを精査した結果、全て Karabiner 固有機能に依存しており hidutil では代替不可。

| # | 内容 | 使用機能 | hidutil |
|---|---|---|---|
| 1 | 端末で `left_control` を tap 時のみ短時間保持 | tap/hold 判定 (`to_if_alone`) + アプリ条件 | ❌ |
| 2 | 端末で `Ctrl+b` → `英数` → `Ctrl+b` | 複数キー出力 + アプリ条件 | ❌ |
| 3 | `Ctrl+,` → `Alt+←`（単語戻る） | modifier 組み合わせ判定 + modifier 付け替え | ❌ |
| 4 | `Ctrl+.` → `Alt+→` | 同上 | ❌ |
| 5 | `Ctrl+w` → `PageUp` | modifier 組み合わせ判定 | ❌ |
| 6 | `Ctrl+v` → `PageDown` | 同上 | ❌ |
| 7 | `Ctrl+h/j/k/l` → 矢印キー | 同上 | ❌ |

hidutil は `{"src": キーA, "dst": キーB}` の単純な 1:1 入れ替えのみで、以下が一切扱えない:

- modifier との組み合わせ判定
- tap/hold の使い分け
- アプリケーション別の挙動
- 1 キー → 複数キーの展開

## Nix（nix-darwin）で扱える OS 操作の範囲

| カテゴリ | nix-darwin の機能 | 現リポジトリの該当箇所 |
|---|---|---|
| `defaults write` 系 | `system.defaults.*` | `settings.sh` |
| launchd サービス | `launchd.user.agents.*` / `launchd.daemons.*` | （現状なし） |
| sudo の Touch ID 認証 | `security.pam.services.sudo_local.touchIdAuth` | （現状なし） |
| 任意の activation スクリプト | `system.activationScripts.*` | `settings.sh` の任意処理 |
| Homebrew の Brewfile 管理 | `homebrew.*` | `Brewfile` + `install.sh` |
| dotfile の symlink | `home-manager`（`home.file`） | `link.sh` |

## なぜ今は導入しないか

- nix-darwin を動かすには **Nix daemon と nixpkgs 参照が前提**。「パッケージマネージャとしての Nix を一切使わない」状態では成立しない
- 現状 `settings.sh` は 3 設定のみで、Nix 導入のオーバーヘッド（flake、daemon、毎回の `darwin-rebuild`）に対してリターンが小さい
- Karabiner も外せないため、Nix 化しても「Karabiner + nix-darwin + brew + mise」の並存になり構成が複雑化するだけ

## 再検討のトリガー

以下のいずれかが発生したタイミングで再検討する:

- `launchd` で常駐ジョブを増やす要件が出てきた
- macOS 設定を 20〜30 項目以上宣言的に管理したくなった
- 複数マシン間で OS 設定を厳密に同期する必要が出てきた
