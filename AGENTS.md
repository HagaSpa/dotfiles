# Repository Guidelines

## Project Structure & Module Organization
- `.config/`:
  - `zsh/alias.sh`, `zsh/command.sh` – aliases, workspace helpers, and fzf history functions
  - `tmux/tmux.conf`, `ghostty/config`, `sheldon/plugins.toml`, `cursor/settings.json`, `karabiner/...`
- Root configs: `.zshrc`, `.vimrc`, `Brewfile`
- Scripts: `install.sh` (bootstrap tools), `link.sh` (create symlinks with backups)
- Automation: `.github/workflows/*.yml` and `.github/scripts/*.sh`
- Claude Code: `.claude/` settings, commands, and usage docs

## Build, Test, and Development Commands
- `./install.sh`: Install Homebrew, apply `Brewfile`, set up nvm + Node LTS, global CLIs, and Google Cloud CLI.
- `./link.sh`: Symlink repo configs into `$HOME`; existing files are backed up as `*.bak`.
- `brew bundle --file=./Brewfile`: Reconcile Homebrew packages locally.
- CI mirrors local checks on macOS via `.github/workflows/test-scripts.yml`.
  - Run targeted checks locally when needed: `.github/scripts/test-install.sh`, `test-link.sh`, `test-config.sh`, `test-brewfile.sh`.

## Coding Style & Naming Conventions
- Shell: prefer POSIX sh for portability; use bash features only when needed.
- Safety: enable strict modes (`set -euo pipefail`) in bash/zsh scripts.
- Formatting: 2-space indentation; keep functions small and self-contained.
- Naming: aliases lowercase (`ls`, `l`); concise functions (`gw`, `hagaspa`, `OLTAInc`); hyphenated helper names acceptable in zsh (e.g., `fzf-select-history`).
- Executables: make scripts runnable and add shebangs (e.g., `#!/bin/bash`).

## Testing Guidelines
- Syntax: `bash -n install.sh` and `bash -n link.sh` before PRs.
- Local validation: `brew bundle check --file=./Brewfile`; run `.github/scripts/test-*.sh` on macOS.
- CI: ensure the “Test Scripts” workflow passes; avoid introducing interactive prompts in CI paths.

## Commit & Pull Request Guidelines
- Use Conventional Commits seen in history: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `ci:` (optional scope, e.g., `chore(zsh): ...`).
- PRs: include purpose, summary of changes, relevant output snippets (e.g., `link.sh` logs), and link issues.
- Requirements: pass CI, keep changes atomic, and update `README.md` when behavior changes.

## Security & Configuration Tips
- Review scripts before running; they modify home directories. `link.sh` creates backups as `*.bak`.
- Do not commit secrets or machine-specific tokens. Keep editor/CLI auth outside the repo.
- Target platform: macOS (Apple Silicon friendly). Some steps require network access.

