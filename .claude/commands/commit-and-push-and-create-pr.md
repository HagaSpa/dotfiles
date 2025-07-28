---
description: Create a pull request with project template
allowed-tools: ["Bash", "Read", "Write", "TodoWrite", "TodoRead"]
---

# Commit and Push and Create PR

You are a senior software engineer. You need to commit the current changes and create a Pull Request.

1. Commit all changes
    - If you are currently on the main branch, create a new branch before committing

2. Follow the `Conventional Commits` format specified in `CLAUDE.md` for commit messages

3. Push to the remote repository

4. Create a Pull Request targeting the main branch
    ```markdown

    ## Background / 背景

    [English description]
    [日本語の説明]

    ## Changes / 変更内容

    [English changes]
    [日本語の変更内容]

    ## Impact scope / 影響範囲

    [English impact]
    [日本語の影響範囲]

    ## Testing / 動作確認

    - [x] Test item 1 / テスト項目1
    - [x] Test item 2 / テスト項目2
    ```

5. Open the Pull Request in the web browser after creation. `gh pr view --web`
