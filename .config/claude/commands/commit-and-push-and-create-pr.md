---
description: Create a pull request with project template
allowed-tools: ["Bash", "Read", "Write", "TodoWrite", "TodoRead"]
---

# Commit and Push and Create PR

You are a senior software engineer. You need to commit the current changes and create a Pull Request.

## Step 1: Create Branch (if needed)

If you are currently on the main / master / production branch, create a new branch before committing.

### Branch Naming Rules

| Prefix | Usage |
|--------|-------|
| `feat/` | New feature |
| `fix/` | Bug fix |
| `chore/` | Dependencies, config, refactoring |
| `docs/` | Documentation only |
| `test/` | Test additions/modifications |
| `perf/` | Performance improvements |

**Rules:**
- Lowercase only (no uppercase)
- Alphanumeric and hyphens only (no Japanese)
- Use hyphens as separators (no underscores or spaces)
- Maximum 50 characters including prefix
- Descriptive name that explains what the branch does

**Format:** `<prefix>/<short-description>`

**Examples:**
- `feat/add-user-authentication`
- `fix/login-button-style`
- `chore/update-dependencies`

## Step 2: Commit Changes

### Conventional Commits Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
| Type | Usage |
|------|-------|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Dependencies, config |
| `docs` | Documentation only |
| `test` | Test additions/modifications |
| `perf` | Performance improvements |
| `refactor` | Refactoring (no feature/fix) |
| `style` | Code style changes (formatting) |
| `ci` | CI configuration changes |
| `build` | Build system changes |

**Description rules:**
- Start with lowercase
- Use present tense ("add" not "added")
- No period at the end
- 50 characters or less recommended

**Examples:**
- `feat(auth): add user login functionality`
- `fix(api): handle null response from payment service`
- `chore(deps): update axios to v1.6.0`

## Step 3: Push to Remote

Push the branch to the remote repository.

## Step 4: Create Pull Request

Create a Pull Request targeting the main branch with the following template:

```markdown
## Background / 背景

[日本語の説明]

## Changes / 変更内容

[日本語の変更内容]

## Impact scope / 影響範囲

[日本語の影響範囲]

## Testing / 動作確認

- [x] Test item 1 / テスト項目1
- [x] Test item 2 / テスト項目2
```

## Step 5: Open PR in Browser

Open the Pull Request in the web browser after creation: `gh pr view --web`
