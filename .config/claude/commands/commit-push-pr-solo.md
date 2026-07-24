---
description: Solo-dev lightweight PR (human-authored description)
allowed-tools: ["Bash", "Read", "TodoWrite", "TodoRead"]
---

# Commit, Push, and Create a Lightweight PR (Solo)

For solo personal repositories. Even when working alone, keep the PR as a self-review checkpoint to eyeball the diff before merge. The PR body, however, is **written by the human in their own words**. The AI must not generate or embellish it.

This is a different command from `commit-and-push-and-create-pr` (the work-oriented version where the AI generates the body). Do not confuse the two.

## Step 0: Guard the branch

First check the current branch (`git branch --show-current`). This is mandatory every time, to prevent accidental direct commits to main.

## Step 1: Create Branch (if needed)

If you are on main / master, create a branch before committing.

Naming: `<prefix>/<short-description>` (lowercase, alphanumeric and hyphens only, 50 chars max).
Prefixes: `feat` / `fix` / `chore` / `docs` / `test` / `perf` / `refactor` / `style` / `ci` / `build`

## Step 2: Commit

Commit in Conventional Commits format (the AI may draft the commit message).

```
<type>[optional scope]: <description>
```
- Start with lowercase, present tense, no trailing period, ~50 chars.

## Step 3: Push

Push the branch to the remote.

## Step 4: Summarize the diff and ask the human for one line

Before creating the PR:

1. Present a summary of the diff **in a few lines** (what was added/changed/removed — facts only, no embellishment).
2. Prompt the human: "Give me one line to describe this PR."

## Step 5: Create the PR — body is verbatim from the user

- The PR body is **the human's one line, used verbatim**.
- The AI must not expand, paraphrase, or add template sections. Limit edits to fixing typos or line-break formatting.
- If the human says "no body needed," create the PR with an empty body.
- The PR title may reuse the commit message.

Create it with `gh pr create`, targeting main as the base.

## Step 6: Open in Browser

Open it in the browser after creation: `gh pr view --web`
