return {
  -- Gutter diff bars + hunk actions (Zed-like)
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

  -- Repo-wide views, on top of snacks (already installed for the picker).
  -- git_diff shows staged and unstaged hunks together; <Tab> stages, <C-r> restores.
  -- lazygit gets its theme generated from the colorscheme by snacks, which also
  -- sets os.editPreset=nvim-remote so `e` opens files in this nvim.
  {
    'folke/snacks.nvim',
    keys = {
      { '<leader>gg', function() Snacks.picker.git_diff() end, desc = 'Git: changed hunks (repo)' },
      { '<leader>gf', function() Snacks.picker.git_status() end, desc = 'Git: changed files (repo)' },
      { '<leader>gG', function() Snacks.lazygit() end, desc = 'Git: lazygit (float)' },
      { '<leader>gl', function() Snacks.lazygit.log() end, desc = 'Git: lazygit log' },
    },
  },
}
