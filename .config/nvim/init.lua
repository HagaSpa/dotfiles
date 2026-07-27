-- Neovim config. Plugins managed by lazy.nvim.
-- Editor settings live in lua/config/, plugin specs in lua/plugins/ (one file per
-- concern, collected by the `import` below). Plugin-specific keymaps stay with
-- their spec; lua/config/keymaps.lua holds only editor-native ones.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')

-- ===== Bootstrap lazy.nvim =====
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- lazy-lock.json is written to stdpath('config'), which lands in this repo
-- because link.sh symlinks the whole .config/nvim directory. Linking init.lua
-- alone would put the lockfile outside the repo.
require('lazy').setup({ { import = 'plugins' } }, {
  change_detection = { notify = false },
})

require('config.keymaps')
require('config.autocmds')
require('config.lsp')
