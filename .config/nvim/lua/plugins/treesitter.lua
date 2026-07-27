return {
  -- main branch; required for Neovim 0.11+ / 0.12
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
      -- Grouped so that re-running config (`:Lazy reload`) replaces the autocmd
      -- instead of stacking another copy.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },
}
