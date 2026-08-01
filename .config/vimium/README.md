# Vimium C Configuration

`vimium-c.json` is a [Vimium C](https://github.com/gdh1995/vimium-c) settings export. It is **not symlinked** — extensions read their settings from `chrome.storage`, not from disk, so `link.sh` has no destination to point at. The repo copy is the source of truth; the browser copy is applied by importing.

## Apply to the browser

Vimium C Options → *Backup and restore* → **Import** → pick this file → **Save**.

There is no way to automate this. Browser extensions cannot read a local path like `~/.vimiumrc`; upstream declined the request for exactly that reason ([philc/vimium#3997](https://github.com/philc/vimium/issues/3997)). The only automatic propagation available is Chrome Sync (`vimSync: true`), which copies settings between signed-in browsers but never reads from this repo.

## Update the repo copy

Edit settings in the Options UI, then Options → *Backup and restore* → **Export** and overwrite this file. Exporting rewrites `@time` / `time` / `environment`, so those fields churn on every round trip — that is expected.

Hand-editing `keyMappings` here and importing works too, and keeps the diff clean.

## Current mappings

```
map <c-6> visitPreviousTab
```

Ctrl+6 jumps to the previously-visited tab — a toggle between two, not a history stack. It is the same chord and the same behaviour as nvim's `CTRL-^` (`:h CTRL-^`, alternate file; the terminal collapses Ctrl+6 and Ctrl+Shift+6 to the same byte, so `CTRL-^` answers to both) and Zed's `pane::AlternateFile`. **Zed only ships `ctrl-^`, so `.config/zed/keymap.json` adds `ctrl-6` explicitly** — change one side and the three stop matching.

`<c-6>` is confirmed working; `<c-^>` was not tested. The default `^` binding for the same command is left in place.

Vimium C is inactive on `chrome://` pages and the Chrome Web Store, where extensions cannot inject scripts — the key falls through to the browser there.
