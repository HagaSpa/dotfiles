return {
  -- Project management (Zed-like: pick a dir -> swap session)
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
      -- Match the workspace conventions from CLAUDE.md
      projects = {
        '~/workspaces/*/*',
        '~/worktrees/*/*/*',
      },
      picker = { type = 'snacks' },
      -- Launch into the cwd, not the last project (predictable, Zed-like)
      last_session_on_startup = false,
    },
    keys = {
      { '<leader>fp', '<cmd>NeovimProjectDiscover<CR>', desc = 'Discover projects' },
      { '<leader>fP', '<cmd>NeovimProjectHistory<CR>', desc = 'Recent projects' },
    },
  },

  -- File explorer (edit the filesystem like a buffer)
  {
    'stevearc/oil.nvim',
    lazy = false, -- so it can hijack netrw and open directories on startup
    opts = {
      -- Take over netrw so `:e <dir>` and `<leader>e` open oil, not netrw
      default_file_explorer = true,
      view_options = {
        show_hidden = true, -- match telescope find_files (hidden = true)
      },
    },
    keys = {
      { '<leader>e', '<cmd>Oil<CR>', desc = 'Open parent dir (oil)' },
    },
  },
}
