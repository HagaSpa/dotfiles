-- Neovim config. Plugins managed by lazy.nvim.
-- Minimal starter: lazy.nvim + neovim-project + telescope + treesitter + mason.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ===== Options =====
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = 'yes'
opt.scrolloff = 8
opt.wrap = false

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitright = true
opt.splitbelow = true

opt.swapfile = false
opt.backup = false
opt.undofile = true

opt.termguicolors = true
opt.showmode = false
opt.updatetime = 250
opt.timeoutlen = 400

opt.clipboard = 'unnamedplus'
opt.completeopt = { 'menuone', 'noselect', 'noinsert' }

-- Built-in fuzzy file find via :find (kept as a fallback alongside telescope)
opt.path:append('**')
opt.wildmode = 'longest:full,full'
opt.wildignore:append({ '*/node_modules/*', '*/.git/*', '*/dist/*', '*/build/*' })

-- ===== Bootstrap lazy.nvim =====
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- init.lua is symlinked from the dotfiles repo; resolve it so the lockfile is
-- written directly into the repo dir (no symlink -> atomic writes stay safe).
local repo_config = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.stdpath('config') .. '/init.lua'), ':h')

require('lazy').setup({
  -- Fuzzy finder ------------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({})
      telescope.load_extension('fzf')
    end,
  },

  -- Project management (Zed-like: pick a dir -> swap session) ---------------
  {
    'coffebar/neovim-project',
    lazy = false,
    priority = 100,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
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
      picker = { type = 'telescope' },
      -- Launch into the cwd, not the last project (predictable, Zed-like)
      last_session_on_startup = false,
    },
  },

  -- Treesitter (main branch; required for Neovim 0.11+ / 0.12) --------------
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install({
        'lua', 'vim', 'vimdoc', 'bash', 'yaml', 'json',
        'markdown', 'markdown_inline', 'terraform', 'dockerfile',
      })
      -- Highlighting is a built-in feature enabled per filetype.
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'lua', 'vim', 'help', 'sh', 'bash', 'yaml',
          'json', 'markdown', 'terraform', 'dockerfile' },
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },

  -- LSP server installer (binaries only; LSP itself stays native below) ------
  { 'mason-org/mason.nvim', opts = {} },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    opts = { ensure_installed = { 'yaml-language-server' } },
  },
}, {
  -- lazy.nvim options
  lockfile = repo_config .. '/lazy-lock.json',
  change_detection = { notify = false },
})

-- ===== Keymaps =====
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Window navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Center cursor on big jumps / search
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

-- Paste without yanking replaced text
map('x', '<leader>p', '"_dP')

-- File explorer (built-in netrw)
map('n', '<leader>e', '<cmd>Explore<CR>')

-- Telescope
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = 'Find files' })
map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = 'Live grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = 'Buffers' })
map('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = 'Help tags' })
map('n', '<leader>fd', '<cmd>Telescope diagnostics<CR>', { desc = 'Diagnostics' })

-- Projects (Zed cmd+opt+o equivalent)
map('n', '<leader>fp', '<cmd>NeovimProjectDiscover<CR>', { desc = 'Discover projects' })
map('n', '<leader>fP', '<cmd>NeovimProjectHistory<CR>', { desc = 'Recent projects' })

-- Buffer cycling
map('n', '[b', '<cmd>bprevious<CR>')
map('n', ']b', '<cmd>bnext<CR>')

map('n', '<leader>w', '<cmd>write<CR>')
map('n', '<leader>q', '<cmd>quit<CR>')

-- ===== Autocommands =====
local augroup = vim.api.nvim_create_augroup('user', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup,
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- ===== LSP (native, nvim 0.11+) =====
-- yaml-language-server binary is installed by mason (its bin dir is on PATH).
-- Kubernetes schema scoped to bons8i-style kustomize layout.
vim.lsp.config('yamlls', {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml' },
  root_markers = { '.git' },
  settings = {
    yaml = {
      schemas = {
        kubernetes = {
          'base/**/*.yaml',
          'overlays/**/*.yaml',
          'clusters/**/*.yaml',
        },
      },
      validate = true,
      completion = true,
      hover = true,
    },
  },
})
vim.lsp.enable('yamlls')

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(args)
    local buf = args.buf
    local opts = { buffer = buf }
    map('n', 'K', vim.lsp.buf.hover, opts)
    map('n', 'gd', vim.lsp.buf.definition, opts)
    map('n', '<leader>rn', vim.lsp.buf.rename, opts)
    map('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    map('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
    map('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
    map('n', '<leader>d', vim.diagnostic.open_float, opts)
    vim.lsp.completion.enable(true, args.data.client_id, buf, { autotrigger = true })
  end,
})
