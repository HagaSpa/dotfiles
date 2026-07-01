-- Minimal neovim config. No plugin manager, built-ins only.

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

-- Built-in fuzzy file find via :find
opt.path:append('**')
opt.wildmode = 'longest:full,full'
opt.wildignore:append({ '*/node_modules/*', '*/.git/*', '*/dist/*', '*/build/*' })

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

-- File / buffer navigation (built-in)
map('n', '<leader>e', '<cmd>Explore<CR>')
map('n', '<leader>f', ':find ')
map('n', '<leader>b', ':buffer ')
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

-- ===== LSP =====
-- yaml-language-server (Kubernetes schema scoped to bons8i-style kustomize layout)
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
