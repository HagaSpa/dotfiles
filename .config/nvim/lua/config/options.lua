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

opt.path:append('**')
opt.wildmode = 'longest:full,full'
opt.wildignore:append({ '*/node_modules/*', '*/.git/*', '*/dist/*', '*/build/*' })
