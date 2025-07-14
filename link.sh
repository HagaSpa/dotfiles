#!/bin/bash

set -euo pipefail  # エラー時に停止、未定義変数をエラーとする

# スクリプトの実行ディレクトリを取得（どこから実行されても正しく動作）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

files_and_paths=(
  ".config/zsh/alias.sh:~/.config/zsh/alias.sh"
  ".config/zsh/command.sh:~/.config/zsh/command.sh"
  ".config/karabiner/assets/complex_modifications/personal_hagaspa.json:~/.config/karabiner/assets/complex_modifications/personal_hagaspa.json"
  ".zshrc:~/.zshrc"
  ".vimrc:~/.vimrc"
)

# ログ出力関数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# シンボリックリンクを作成する関数
create_symlink() {
  local source_file="$SCRIPT_DIR/$1"
  local destination_path=$(eval echo $2)  # ~ を展開
  local backup_file="${destination_path}.bak"

  # ソースファイルの存在確認
  if [[ ! -f "$source_file" ]]; then
    log "ERROR: Source file does not exist: $source_file"
    return 1
  fi

  # 宛先ディレクトリの作成
  local dest_dir=$(dirname "$destination_path")
  if [[ ! -d "$dest_dir" ]]; then
    log "Creating directory: $dest_dir"
    mkdir -p "$dest_dir"
  fi

  # 既存ファイル/シンボリンクの処理
  if [[ -e "$destination_path" || -L "$destination_path" ]]; then
    if [[ -L "$destination_path" ]]; then
      local current_target=$(readlink "$destination_path")
      if [[ "$current_target" == "$source_file" ]]; then
        log "Symlink already correct: $destination_path -> $source_file"
        return 0
      fi
    fi
    log "Backing up existing file: $destination_path -> $backup_file"
    mv "$destination_path" "$backup_file"
  fi

  # シンボリックリンクの作成
  log "Creating symlink: $destination_path -> $source_file"
  ln -s "$source_file" "$destination_path"

  # 検証
  if [[ -L "$destination_path" ]] && [[ "$(readlink "$destination_path")" == "$source_file" ]]; then
    log "SUCCESS: Symlink created successfully"
  else
    log "ERROR: Failed to create symlink"
    return 1
  fi
}

# メイン処理
main() {
  log "Starting dotfiles linking process..."
  log "Script directory: $SCRIPT_DIR"
  
  local success_count=0
  local total_count=${#files_and_paths[@]}
  
  for entry in "${files_and_paths[@]}"; do
    IFS=":" read -r source_file destination_path <<< "$entry"
    log "Processing: $source_file -> $destination_path"
    
    if create_symlink "$source_file" "$destination_path"; then
      ((success_count++))
    else
      log "FAILED: $source_file"
    fi
    echo
  done
  
  log "Completed: $success_count/$total_count symlinks processed successfully"
  
  if [[ $success_count -eq $total_count ]]; then
    log "All symlinks created successfully! ✅"
    log "You may want to restart your shell or run: source ~/.zshrc"
  else
    log "Some symlinks failed. Please check the errors above. ❌"
    exit 1
  fi
}

# スクリプト実行
main "$@"
