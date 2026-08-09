return {
  {
    'coffebar/neovim-project',
    lazy = false,
    priority = 100,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/snacks.nvim',
      'Shatur/neovim-session-manager',
    },
    init = function()
      -- needed so buffers/layout are stored per project
      vim.opt.sessionoptions:append('globals')
    end,
    opts = {
      projects = {
        '~/workspaces/*/*',
        '~/worktrees/*/*/*',
      },
      picker = { type = 'snacks' },
      last_session_on_startup = false,
    },
    keys = {
      { '<leader>fp', '<cmd>NeovimProjectDiscover<CR>', desc = 'Discover projects' },
      { '<leader>fP', '<cmd>NeovimProjectHistory<CR>', desc = 'Recent projects' },
    },
  },

  {
    'stevearc/oil.nvim',
    lazy = false, -- required for the netrw hijack below to take effect
    opts = {
      -- paired with snacks explorer's replace_netrw = false (plugins/picker.lua)
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
    },
    keys = {
      { '<leader>e', '<cmd>Oil<CR>', desc = 'Open parent dir (oil)' },
    },
  },
}
