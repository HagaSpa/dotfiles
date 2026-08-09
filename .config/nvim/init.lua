vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- lazy-lock.json is written to stdpath('config'). link.sh must keep symlinking the
-- whole .config/nvim directory; linking init.lua alone puts the lockfile outside the repo.
require('lazy').setup({ { import = 'plugins' } }, {
  change_detection = { notify = false },
})

require('config.keymaps')
require('config.autocmds')
require('config.lsp')
