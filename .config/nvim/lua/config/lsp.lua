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

-- Delta only: nvim merges this onto vim.lsp.protocol.make_client_capabilities().
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities({}, false),
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

-- gofumpt / staticcheck are built into gopls; there are no separate binaries.
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      analyses = { unusedparams = true, shadow = true },
    },
  },
})

vim.lsp.enable({ 'yamlls', 'rust_analyzer', 'ts_ls', 'ty', 'gopls' })

-- Go alone formats on save: the language expects imports to be maintained by the
-- tooling, so editing one by hand is not part of the workflow.
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup,
  pattern = '*.go',
  callback = function(args)
    local client = vim.lsp.get_clients({ bufnr = args.buf, name = 'gopls' })[1]
    if not client then
      return
    end
    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = { only = { 'source.organizeImports' }, diagnostics = {} }
    -- 1000ms is not enough for the first save of a session: gopls loads the package first.
    local responses = vim.lsp.buf_request_sync(args.buf, 'textDocument/codeAction', params, 3000)
    for _, response in pairs(responses or {}) do
      for _, action in pairs(response.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
        end
      end
    end
    vim.lsp.buf.format({ bufnr = args.buf, async = false, timeout_ms = 3000 })
  end,
})

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
  end,
})
