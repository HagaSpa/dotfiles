-- Neovim config. Plugins managed by lazy.nvim.
-- Minimal starter: lazy.nvim + neovim-project + snacks.picker + treesitter + mason.

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

-- Built-in fuzzy file find via :find (kept as a fallback alongside the picker)
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
  -- Colorscheme (kanagawa; muted wabi-sabi palette) -------------------------
  {
    'rebelot/kanagawa.nvim',
    priority = 1000, -- load before everything so early UI is themed
    config = function()
      vim.cmd.colorscheme('kanagawa')
    end,
  },

  -- File icons (per-filetype icons for the snacks picker) -------------------
  {
    'echasnovski/mini.icons',
    opts = {},
  },

  -- Fuzzy finder ------------------------------------------------------------
  {
    'folke/snacks.nvim',
    priority = 1000,
    dependencies = { 'echasnovski/mini.icons' },
    opts = {
      -- Only the picker module; explorer/dashboard/notifier etc. stay off
      -- (oil.nvim already owns the file-explorer role).
      picker = {
        enabled = true,
        sources = {
          -- match the old telescope config: show dotfiles, skip .gitignored
          files = { hidden = true },
          grep = { hidden = true },
        },
        matcher = { frecency = true },
      },
    },
  },

  -- Keymap hints (popup of what is bound under the prefix just typed) -------
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      -- Mappings without a desc are noise here (and unsearchable in the picker).
      filter = function(mapping)
        return mapping.desc ~= nil and mapping.desc ~= ''
      end,
      spec = {
        { '<leader>c', group = 'code' },
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git' },
        { '<leader>r', group = 'refactor' },
      },
    },
    keys = {
      {
        '<leader>?',
        function() require('which-key').show({ global = false }) end,
        desc = 'Buffer-local keymaps',
      },
    },
  },

  -- Project management (Zed-like: pick a dir -> swap session) ---------------
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
  },

  -- File explorer (edit the filesystem like a buffer) ----------------------
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
  },

  -- Git signs (gutter bars + inline hunk diff, Zed-like) -------------------
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      -- The defaults already draw a thick bar (┃); only staged is overridden, to
      -- a thin bar. gitsigns dims staged signs to 50% fg on top of that.
      signs_staged = {
        add = { text = '│' },
        change = { text = '│' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        -- vim.keymap.set, not the `map` local below: that local is declared
        -- after this chunk, so it is not in scope here.
        local function gmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'Git: ' .. desc })
        end

        gmap('n', ']c', function()
          -- Keep the built-in ]c / [c when this buffer is in a real diff split
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gs.nav_hunk('next')
          end
        end, 'Next hunk')
        gmap('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gs.nav_hunk('prev')
          end
        end, 'Prev hunk')

        gmap('n', '<leader>gp', gs.preview_hunk, 'Preview hunk (float)')
        gmap('n', '<leader>gi', gs.preview_hunk_inline, 'Preview hunk (inline)')
        gmap('n', '<leader>gs', gs.stage_hunk, 'Stage hunk')
        gmap('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
        gmap('v', '<leader>gs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage selected lines')
        gmap('v', '<leader>gr', function()
          gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Reset selected lines')
        gmap('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
        gmap('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')
        gmap('n', '<leader>gb', function()
          gs.blame_line({ full = true })
        end, 'Blame line')
        gmap('n', '<leader>gB', gs.toggle_current_line_blame, 'Toggle inline blame')
        gmap('n', '<leader>gw', gs.toggle_word_diff, 'Toggle word diff')
        gmap('n', '<leader>gd', gs.diffthis, 'Diff against index')
        gmap('n', '<leader>gD', function()
          gs.diffthis('~')
        end, 'Diff against last commit')
        gmap({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select hunk')
      end,
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
        'javascript', 'typescript', 'tsx', 'rust', 'go', 'python',
      })
      -- Highlighting is a built-in feature enabled per filetype. Start it for
      -- any filetype whose parser is installed; pcall no-ops when there is none,
      -- so the install list above is the single source of truth.
      vim.api.nvim_create_autocmd('FileType', {
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },

  -- LSP servers are installed via brew (Brewfile) / mise (.mise.toml), not a
  -- plugin. The native client below launches them off $PATH.
}, {
  -- lazy.nvim options
  lockfile = repo_config .. '/lazy-lock.json',
  change_detection = { notify = false },
})

-- ===== Keymaps =====
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Window navigation
map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

-- Center cursor on big jumps / search
map('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })
map('n', 'n', 'nzzzv', { desc = 'Next search match (centered)' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search match (centered)' })

-- Paste without yanking replaced text
map('x', '<leader>p', '"_dP', { desc = 'Paste over selection (keep register)' })

-- File explorer (oil.nvim: edit the filesystem like a buffer)
map('n', '<leader>e', '<cmd>Oil<CR>', { desc = 'Open parent dir (oil)' })
map('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent dir (oil)' })

-- Picker (snacks.nvim)
map('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Find files' })
map('n', '<leader>fg', function() Snacks.picker.grep() end, { desc = 'Live grep' })
map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Buffers' })
map('n', '<leader>fh', function() Snacks.picker.help() end, { desc = 'Help tags' })
map('n', '<leader>fd', function() Snacks.picker.diagnostics() end, { desc = 'Diagnostics' })
-- Self-documentation: search every keymap / ex-command by its desc, run with <CR>.
-- Every map below carries a desc so these two stay useful.
map('n', '<leader>fk', function() Snacks.picker.keymaps() end, { desc = 'Keymaps (search what is bound)' })
map('n', '<leader>fc', function() Snacks.picker.commands() end, { desc = 'Ex commands' })

-- Git, repo-wide (the hunk-level maps are buffer-local; see gitsigns above).
-- git_diff shows staged and unstaged hunks together; <Tab> stages, <C-r> restores.
map('n', '<leader>gg', function() Snacks.picker.git_diff() end, { desc = 'Git: changed hunks (repo)' })
map('n', '<leader>gf', function() Snacks.picker.git_status() end, { desc = 'Git: changed files (repo)' })
-- lazygit in a float. Snacks generates the theme from the colorscheme and sets
-- os.editPreset=nvim-remote, so `e` opens files in this nvim, not a nested one.
map('n', '<leader>gG', function() Snacks.lazygit() end, { desc = 'Git: lazygit (float)' })
map('n', '<leader>gl', function() Snacks.lazygit.log() end, { desc = 'Git: lazygit log' })

-- Projects (Zed cmd+opt+o equivalent)
map('n', '<leader>fp', '<cmd>NeovimProjectDiscover<CR>', { desc = 'Discover projects' })
map('n', '<leader>fP', '<cmd>NeovimProjectHistory<CR>', { desc = 'Recent projects' })

map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Write file' })
map('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit window' })

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

-- ===== Diagnostics =====
-- virtual_text is off by default, so show the message on jump instead. This hooks
-- Neovim's own [d / ]d maps; do not re-map those keys here.
vim.diagnostic.config({
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = 'cursor' })
    end,
  },
})

-- ===== LSP (native, nvim 0.11+) =====
-- yaml-language-server binary comes from brew (Brewfile); it is on $PATH.
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

-- Servers below come from brew (Brewfile) / mise (.mise.toml); all on $PATH:
--   rust-analyzer -> mise | typescript-language-server -> brew
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
vim.lsp.enable({ 'rust_analyzer', 'ts_ls' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(args)
    local buf = args.buf
    local function lmap(lhs, rhs, desc)
      map('n', lhs, rhs, { buffer = buf, desc = 'LSP: ' .. desc })
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
