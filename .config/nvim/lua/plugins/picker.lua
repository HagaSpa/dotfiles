return {
  -- File icons (per-filetype icons for the snacks picker)
  {
    'echasnovski/mini.icons',
    opts = {},
  },

  -- Fuzzy finder
  {
    'folke/snacks.nvim',
    priority = 1000,
    dependencies = { 'echasnovski/mini.icons' },
    opts = {
      -- Only picker + explorer; dashboard/notifier etc. stay off.
      -- oil.nvim stays the netrw replacement (`:e <dir>`); the explorer is a
      -- persistent sidebar tree, opened on demand.
      explorer = {
        enabled = true,
        replace_netrw = false, -- default is true, which would fight oil.nvim
      },
      picker = {
        enabled = true,
        sources = {
          -- match the old telescope config: show dotfiles, skip .gitignored
          files = { hidden = true },
          grep = { hidden = true },
          explorer = {
            hidden = true,
            layout = { layout = { position = 'right' } },
          },
        },
        matcher = { frecency = true },
      },
    },
    keys = {
      -- Snacks.explorer() closes an already-open explorer, so this is a toggle
      { '<leader>E', function() Snacks.explorer() end, desc = 'File tree sidebar (toggle)' },
      { '<leader>ff', function() Snacks.picker.files() end, desc = 'Find files' },
      { '<leader>fg', function() Snacks.picker.grep() end, desc = 'Live grep' },
      { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>fh', function() Snacks.picker.help() end, desc = 'Help tags' },
      { '<leader>fd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
      -- Self-documentation: search every keymap / ex-command by its desc, run with
      -- <CR>. Every map in this config carries a desc so these two stay useful.
      { '<leader>fk', function() Snacks.picker.keymaps() end, desc = 'Keymaps (search what is bound)' },
      { '<leader>fc', function() Snacks.picker.commands() end, desc = 'Ex commands' },
    },
  },
}
