-- Editor-native keymaps. Plugin-specific ones live with their plugin spec in
-- lua/plugins, so changing a plugin's UX means editing one file.
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

map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Write file' })
map('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit window' })
