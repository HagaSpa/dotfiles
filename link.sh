#!/bin/bash

files_and_paths=(
  ".config/zsh/alias.sh:~/.config/zsh/alias.sh"
  ".config/zsh/command.sh:~/.config/zsh/command.sh"
  ".config/karabiner/assets/complex_modifications/personal_hagaspa.json:~/.config/karabiner/assets/complex_modifications/personal_hagaspa.json"
  ".zshrc:~/.zshrc"
  ".vimrc:~/.vimrc"
)

# シンボリックリンクを作成する関数
create_symlink() {
  local source_file=$(realpath $1)
  local destination_path=$(eval echo $2)  # ~ を展開

  backup_file="${destination_path}.bak"     # 退避先のファイル名

  if [ -e "$destination_path" ]; then
    mv "$destination_path" "$backup_file"
  fi

  ln -s "$source_file" "$destination_path"  # シンボリックリンクの作成
}

for entry in "${files_and_paths[@]}"; do
  IFS=":" read -r source_file destination_path <<< "$entry"
  create_symlink "$source_file" "$destination_path"
done
