-- Own group, separate from config/lsp.lua: two modules clearing the same group
-- would silently delete each other's autocmds.
local augroup = vim.api.nvim_create_augroup('user_autocmds', { clear = true })

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
