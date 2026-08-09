return {
  -- Staging / reset is lazygit's job; gitsigns deliberately maps neither.
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
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
        gmap('n', '<leader>gb', function()
          gs.blame_line({ full = true })
        end, 'Blame line')
        gmap('n', '<leader>gB', gs.toggle_current_line_blame, 'Toggle inline blame')
        gmap('n', '<leader>gw', gs.toggle_word_diff, 'Toggle word diff')
        gmap({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select hunk')
      end,
    },
  },

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
