return {
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('kanagawa')
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
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
