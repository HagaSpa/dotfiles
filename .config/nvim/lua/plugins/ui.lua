return {
  -- Colorscheme (kanagawa; muted wabi-sabi palette)
  {
    'rebelot/kanagawa.nvim',
    priority = 1000, -- load before everything so early UI is themed
    config = function()
      vim.cmd.colorscheme('kanagawa')
    end,
  },

  -- Keymap hints (popup of what is bound under the prefix just typed)
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      -- Mappings without a desc are noise here (and unsearchable in the picker).
      filter = function(mapping)
        return mapping.desc ~= nil and mapping.desc ~= ''
      end,
      spec = {
        { '<leader>c', group = 'code' },
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git' },
        { '<leader>r', group = 'refactor' },
      },
    },
    keys = {
      {
        '<leader>?',
        function() require('which-key').show({ global = false }) end,
        desc = 'Buffer-local keymaps',
      },
    },
  },
}
