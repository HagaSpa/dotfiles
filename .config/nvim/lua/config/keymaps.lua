-- Editor-native keymaps. Plugin-specific ones live with their plugin spec in
-- lua/plugins, so changing a plugin's UX means editing one file.
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Ctrl+hjkl は Karabiner (内蔵キーボード) と QMK (7sPro) が矢印に変換するため
-- ここに割り当てても届かない。ウィンドウ移動は <C-w>hjkl を直接使う。

-- Center cursor on big jumps / search
map('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)' })
map('n', 'n', 'nzzzv', { desc = 'Next search match (centered)' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search match (centered)' })

-- Paste without yanking replaced text
map('x', '<leader>p', '"_dP', { desc = 'Paste over selection (keep register)' })

map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Write file' })
map('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit window' })
