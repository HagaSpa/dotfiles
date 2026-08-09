return {
  {
    'echasnovski/mini.icons',
    opts = {},
  },

  {
    'folke/snacks.nvim',
    priority = 1000,
    dependencies = { 'echasnovski/mini.icons' },
    opts = {
      explorer = {
        enabled = true,
        replace_netrw = false, -- default is true, which would fight oil.nvim
      },
      picker = {
        enabled = true,
        sources = {
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
      { '<leader>E', function() Snacks.explorer() end, desc = 'File tree sidebar (toggle)' },
      { '<leader>ff', function() Snacks.picker.files() end, desc = 'Find files' },
      { '<leader>fg', function() Snacks.picker.grep() end, desc = 'Live grep' },
      { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>fh', function() Snacks.picker.help() end, desc = 'Help tags' },
      { '<leader>fd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
      { '<leader>fk', function() Snacks.picker.keymaps() end, desc = 'Keymaps (search what is bound)' },
      { '<leader>fc', function() Snacks.picker.commands() end, desc = 'Ex commands' },
    },
  },
}
