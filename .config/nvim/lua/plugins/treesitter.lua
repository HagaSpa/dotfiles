return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main', -- master does not support Neovim 0.11+
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install({
        'lua', 'vim', 'vimdoc', 'bash', 'yaml', 'json',
        'markdown', 'markdown_inline', 'terraform', 'dockerfile',
        'javascript', 'typescript', 'tsx', 'astro', 'css',
        'rust', 'go', 'python',
      })
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },
}
