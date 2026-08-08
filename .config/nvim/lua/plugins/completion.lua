return {
  {
    'saghen/blink.cmp',
    -- No lazy-loading handler: lua/config/lsp.lua requires this at startup.
    version = '1.*',
    opts = {
      keymap = {
        preset = 'super-tab',
        -- The preset's <C-space> is the tmux prefix (.config/tmux/tmux.conf).
        ['<C-g>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = true },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
}
