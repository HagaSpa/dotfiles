-- Native LSP (nvim 0.11+). Servers are installed via brew (Brewfile) / mise
-- (.mise.toml) and launched off $PATH -- no mason.
--
-- Own group, separate from config/autocmds.lua (see the note there).
local augroup = vim.api.nvim_create_augroup('user_lsp', { clear = true })

-- virtual_text is off by default, so show the message on jump instead. This hooks
-- Neovim's own [d / ]d maps; do not re-map those keys here.
vim.diagnostic.config({
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = 'cursor' })
    end,
  },
})

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

-- rust-analyzer -> mise | typescript-language-server -> brew
vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
})
vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript', 'javascriptreact', 'javascript.jsx',
    'typescript', 'typescriptreact', 'typescript.tsx',
  },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
})
vim.lsp.config('ty', {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'ty.toml', 'pyproject.toml', 'setup.py', '.git' },
})

vim.lsp.enable({ 'yamlls', 'rust_analyzer', 'ts_ls', 'ty' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(args)
    local buf = args.buf
    local function lmap(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = buf, desc = 'LSP: ' .. desc })
    end
    -- Neovim's own grr / gri / grt / gO (:h lsp-defaults) dump results into the
    -- quickfix list; these overrides route them through the snacks picker instead.
    -- Every source auto-confirms on a single result, so the popup only appears
    -- when there is a real choice to make.
    lmap('K', vim.lsp.buf.hover, 'Hover docs')
    lmap('gd', function() Snacks.picker.lsp_definitions() end, 'Go to definition')
    lmap('grr', function() Snacks.picker.lsp_references() end, 'References')
    lmap('gri', function() Snacks.picker.lsp_implementations() end, 'Implementations')
    lmap('grt', function() Snacks.picker.lsp_type_definitions() end, 'Type definitions')
    lmap('gO', function() Snacks.picker.lsp_symbols() end, 'Document symbols')
    lmap('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    lmap('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    lmap('<leader>d', vim.diagnostic.open_float, 'Show diagnostic under cursor')
    vim.lsp.completion.enable(true, args.data.client_id, buf, { autotrigger = true })
  end,
})
