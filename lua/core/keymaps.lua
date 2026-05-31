local map = vim.keymap

-- ─── Escape & Basics ─────────────────────────────────────────────────────────
map.set('i', 'jk', '<Esc>', { noremap = true, silent = true, desc = "Editor: Exit insert mode" })
map.set('i', '<C-H>', '<C-W>', { noremap = true, desc = "Cmd: Delete entire word" })

-- ─── Selection ───────────────────────────────────────────────────────────────
map.set('n', '<Leader>aa', 'ggVG', { noremap = true, silent = true, desc = "Editor: Select all" })

-- ─── Navigation ──────────────────────────────────────────────────────────────
map.set('n', 'n', 'nzz', { noremap = true, silent = true, desc = "Editor: Next search result centered" })
map.set('n', 'N', 'Nzz', { noremap = true, silent = true, desc = "Editor: Prev search result centered" })
map.set("n", "j", function() return vim.v.count == 0 and "gj" or "j" end, { expr = true })
map.set("n", "k", function() return vim.v.count == 0 and "gk" or "k" end, { expr = true })

-- ─── File Operations ─────────────────────────────────────────────────────────
map.set('n', '<Leader>w',  ':w<CR>',   { noremap = true, silent = true, desc = "Editor: Save file" })
map.set('n', '<Leader>q',  ':q!<CR>',  { noremap = true, silent = true, desc = "Editor: Quit without saving" })
map.set('n', '<Leader>bd', ':bd!<CR>', { noremap = true, silent = true, desc = "Editor: Delete buffer" })

map.set('n', '<Leader>yf', function()
    local path = vim.fn.expand('%:p')
    vim.fn.setreg('+', path)
    vim.fn.system({ 'tmux', 'set-buffer', path })
    print('Copied: ' .. path)
end, { desc = 'Editor: Yank file path to clipboard' })

map.set('n', '<Leader>rk', ':source ~/.config/nvim/lua/core/keymaps.lua<CR>')
-- ─── Lua File Execute ────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function(args)
        local bufnr = args.buf
        vim.keymap.set('n', '<Leader>%', function()
            vim.cmd 'source %'
            vim.notify("File sourced!", "info", { id = "source_file" })
        end, { noremap = true, silent = true, desc = "Editor: Source file", buffer = bufnr })
        vim.keymap.set('n', '<Leader>x', function()
            vim.cmd '.lua'
            vim.notify("Line executed!", "info", { id = "execute_line" })
        end, { noremap = true, silent = true, desc = "Editor: Execute current line", buffer = bufnr })
        vim.keymap.set('v', '<Leader>x', function()
            vim.cmd("'<,'>lua")
            vim.notify("Lines executed!", "info", { id = "execute_lines" })
        end, { noremap = true, silent = true, desc = "Editor: Execute selected lines", buffer = bufnr })
    end,
    desc = "Set Lua file/line execute keymaps",
})

-- ─── Tabline ─────────────────────────────────────────────────────────────────
map.set('n', '<A-t>', function()
    vim.opt.showtabline = vim.opt.showtabline._value ~= 2 and 2 or 1
end, { noremap = true, silent = true, desc = "Editor: Toggle tabline" })

-- ─── Window Navigation ───────────────────────────────────────────────────────
map.set('n', '<C-h>', '<C-W><C-h>', { noremap = true, silent = true, desc = "Buffer: Navigate left" })
map.set('n', '<C-l>', '<C-W><C-l>', { noremap = true, silent = true, desc = "Buffer: Navigate right" })
map.set('n', '<C-k>', '<C-W><C-k>', { noremap = true, silent = true, desc = "Buffer: Navigate up" })
map.set('n', '<C-j>', '<C-W><C-j>', { noremap = true, silent = true, desc = "Buffer: Navigate down" })
map.set('n', '<C-Left>',  '<C-W><C-h>', { noremap = true, silent = true, desc = "Buffer: Navigate left" })
map.set('n', '<C-Right>', '<C-W><C-l>', { noremap = true, silent = true, desc = "Buffer: Navigate right" })
map.set('n', '<C-Up>',    '<C-W><C-k>', { noremap = true, silent = true, desc = "Buffer: Navigate up" })
map.set('n', '<C-Down>',  '<C-W><C-j>', { noremap = true, silent = true, desc = "Buffer: Navigate down" })
map.set('n', ']b', ':bn<CR>', { noremap = true, silent = true, desc = "Buffer: Next buffer" })
map.set('n', '[b', ':bp<CR>', { noremap = true, silent = true, desc = "Buffer: Prev buffer" })

-- ─── Window Layout & Resize ──────────────────────────────────────────────────
map.set('n', '<Leader>wh', ':WinShift left<CR>',     { noremap = true, silent = true, desc = "WinShift: Move window left" })
map.set('n', '<Leader>wl', ':WinShift right<CR>',    { noremap = true, silent = true, desc = "WinShift: Move window right" })
map.set('n', '<Leader>wk', ':WinShift up<CR>',       { noremap = true, silent = true, desc = "WinShift: Move window up" })
map.set('n', '<Leader>wj', ':WinShift down<CR>',     { noremap = true, silent = true, desc = "WinShift: Move window down" })
map.set('n', '<Leader>wH', ':WinShift far_left<CR>',  { noremap = true, silent = true, desc = "WinShift: Move window far-left" })
map.set('n', '<Leader>wL', ':WinShift far_right<CR>', { noremap = true, silent = true, desc = "WinShift: Move window far-right" })
map.set('n', '<Leader>wJ', ':WinShift far_down<CR>',  { noremap = true, silent = true, desc = "WinShift: Move window far-down" })
map.set('n', '<Leader>wK', ':WinShift far_up<CR>',    { noremap = true, silent = true, desc = "WinShift: Move window far-up" })
map.set('n', '<Leader>ws', ':WinShift<CR>',           { noremap = true, silent = true, desc = "WinShift: Start move mode" })
map.set('n', '<Leader>wx', ':WinShift swap<CR>',      { noremap = true, silent = true, desc = "WinShift: Swap windows" })
map.set('n', '<A-=>', ':wincmd =<CR>', { noremap = true, silent = true, desc = "Buffer: Rebalance layout" })

local function resize_dynamic(direction)
    local max_windows = #vim.api.nvim_list_wins()
    local col = vim.fn.winnr()
    if direction == "height" then
        vim.cmd(col == max_windows and 'resize -2' or 'resize +2')
    elseif direction == "height_inv" then
        vim.cmd(col == max_windows and 'resize +2' or 'resize -2')
    elseif direction == "width" then
        vim.cmd(col == max_windows and 'vertical resize -2' or 'vertical resize +2')
    elseif direction == "width_inv" then
        vim.cmd(col == max_windows and 'vertical resize +2' or 'vertical resize -2')
    end
end

map.set('n', '<A-j>', function() resize_dynamic("height") end,     { noremap = true, silent = true, desc = "Buffer: Adjust height" })
map.set('n', '<A-k>', function() resize_dynamic("height_inv") end, { noremap = true, silent = true, desc = "Buffer: Adjust height" })
map.set('n', '<A-l>', function() resize_dynamic("width") end,      { noremap = true, silent = true, desc = "Buffer: Adjust width" })
map.set('n', '<A-h>', function() resize_dynamic("width_inv") end,  { noremap = true, silent = true, desc = "Buffer: Adjust width" })

-- ─── Search & Replace ────────────────────────────────────────────────────────
map.set('n', '<Leader>ra', 'yiw:%s/<C-r>"//gc<Left><Left><Left>', { noremap = true, desc = "Editor: Replace all occurrences of word" })
map.set('v', '<Leader>ra', 'y:%s/<C-r>"//gc<Left><Left><Left>',   { noremap = true, desc = "Editor: Replace all occurrences of selection" })
map.set('n', '<Leader>rl', 'yiw:s/<C-r>"//gc<Left><Left><Left>',  { noremap = true, desc = "Editor: Replace word on line" })
map.set('v', '<Leader>rl', 'y:s/<C-r>"//gc<Left><Left><Left>',    { noremap = true, desc = "Editor: Replace selection on line" })
map.set('n', '<Leader>n',  'yiw:let @/ = "<C-r>""<CR>', { noremap = true, desc = "Editor: Search word under cursor" })
map.set('v', '<Leader>n',  'y:let @/ = "<C-r>""<CR>',   { noremap = true, desc = "Editor: Search highlighted word" })

-- ─── Copy / Paste / Delete ───────────────────────────────────────────────────
map.set('n', '<Leader>y', '"+y',  { noremap = true, silent = true, desc = "Editor: Copy motion to clipboard" })
map.set('n', '<Leader>Y', '"+Y',  { noremap = true, silent = true, desc = "Editor: Copy line to clipboard" })
map.set('v', '<Leader>y', '"+y',  { noremap = true, silent = true, desc = "Editor: Copy selection to clipboard" })
map.set('x', '<Leader>p', '"_dP', { noremap = true, silent = true, desc = "Editor: Paste without overwriting clipboard" })
map.set('n', '<Leader>d', '"_d',  { noremap = true, silent = true, desc = "Editor: Delete without affecting yank" })
map.set('v', '<Leader>d', '"_d',  { noremap = true, silent = true, desc = "Editor: Delete selection without affecting yank" })
map.set('n', '<Leader>P', function()
    local reg = vim.fn.getreg('+')
    vim.api.nvim_put({ reg:gsub('\n$', '') }, 'c', true, true)
end, { noremap = true, silent = true, desc = "Editor: Paste clipboard inline after cursor" })

-- ─── Line Manipulation ───────────────────────────────────────────────────────
map.set('v', 'K', ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Editor: Move lines up" })
map.set('v', 'J', ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Editor: Move lines down" })
map.set('n', 'J', 'mzJ`z', { noremap = true, silent = true, desc = "Editor: Join lines, keep cursor" })
map.set('n', '<Tab>',   '>>_', { noremap = true, silent = true, desc = "Editor: Indent" })
map.set('n', '<S-Tab>', '<<_', { noremap = true, silent = true, desc = "Editor: Dedent" })
map.set('v', '<Tab>',   '>gv', { noremap = true, silent = true, desc = "Editor: Indent" })
map.set('v', '<S-Tab>', '<gv', { noremap = true, silent = true, desc = "Editor: Dedent" })

-- ─── Format ──────────────────────────────────────────────────────────────────
map.set('n', '<Leader>=', function()
    local conform_fts = {
        'javascript', 'typescript', 'javascriptreact', 'typescriptreact',
        'svelte', 'css', 'html', 'json', 'yaml', 'markdown',
        'graphql', 'liquid', 'lua', 'python', 'zig',
    }
    local save_cursor = vim.api.nvim_win_get_cursor(0)
    if vim.tbl_contains(conform_fts, vim.bo.filetype) then
        require("conform").format({ lsp_fallback = true, async = false })
    else
        vim.cmd('normal! gg=G')
    end
    vim.api.nvim_win_set_cursor(0, save_cursor)
end, { noremap = true, silent = true, desc = "Editor: Format file" })

-- ─── Messages ────────────────────────────────────────────────────────────────
map.set('n', '<Leader>.', ":new | put =execute('messages') | wincmd J | res -15<CR>", { noremap = true, silent = true, desc = "Messages: Open message history" })

-- ─── Git ─────────────────────────────────────────────────────────────────────
map.set('n', '<leader>gc', function() vim.cmd(":let @/ = '^<\\|^=\\|^>'") end, { noremap = true, desc = "Git: Highlight conflict markers" })

-- ─── Project Picker ──────────────────────────────────────────────────────────
map.set('n', '<leader>pp', function()
    require("custom.project_picker").project_picker()
end, { desc = "Projects: Pick project and set cwd" })

-- ─── Python Runner ───────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(args)
        local bufnr = args.buf
        vim.keymap.set('n', '<Leader>rp', function()
            local file = vim.fn.expand('%:p')
            vim.cmd('ToggleTerminal')
            vim.defer_fn(function()
                local term_buf = vim.fn.bufnr('term://')
                if term_buf ~= -1 then
                    vim.api.nvim_chan_send(vim.bo[term_buf].channel, 'python ' .. file .. '\n')
                end
            end, 100)
        end, { noremap = true, silent = true, desc = "Python: Run current file", buffer = bufnr })
    end,
    desc = "Set Python run keymap",
})

-- ─── Command Line ────────────────────────────────────────────────────────────
map.set('c', '<Esc>', function()
    return vim.fn.pumvisible() ~= 0 and vim.keycode('<C-e>') or vim.keycode('<C-c>')
end, { expr = true, noremap = true, desc = "Cmd: Exit completion or command mode" })
map.set('c', '<Tab>', function()
    return vim.fn.pumvisible() ~= 0 and vim.keycode('<C-y>') or vim.keycode('<C-z>')
end, { expr = true, noremap = true, desc = "Cmd: Accept selection or start completion" })
map.set('c', '<C-n>', function()
    return vim.fn.pumvisible() ~= 0 and vim.keycode('<C-n>') or vim.keycode('<C-z>')
end, { expr = true, noremap = true, desc = "Cmd: Cycle or start completion" })
map.set('c', '<Down>', function()
    return vim.fn.pumvisible() ~= 0 and vim.keycode('<C-n>') or '<Down>'
end, { expr = true, noremap = true, desc = "Cmd: Next completion or history" })
map.set('c', '<Up>', function()
    return vim.fn.pumvisible() ~= 0 and vim.keycode('<C-p>') or '<Up>'
end, { expr = true, noremap = true, desc = "Cmd: Prev completion or history" })
map.set('c', '<Left>', function()
    return vim.fn.pumvisible() ~= 0 and '<Up>' or '<Left>'
end, { expr = true, noremap = true, desc = "Cmd: Expand completion or move left" })
map.set('c', '<Right>', function()
    return vim.fn.pumvisible() ~= 0 and '<Down>' or '<Right>'
end, { expr = true, noremap = true, desc = "Cmd: Expand completion or move right" })
map.set('c', '<C-j>', '<C-n>', { noremap = true, desc = "Cmd: Next completion" })
map.set('c', '<C-k>', '<C-p>', { noremap = true, desc = "Cmd: Prev completion" })
map.set('c', '<C-h>', '<Up>',  { noremap = true, desc = "Cmd: Prev history" })
map.set('c', '<C-l>', '<Down>', { noremap = true, desc = "Cmd: Next history" })
map.set('c', '<C-H>', '<C-W>', { noremap = true, desc = "Cmd: Delete word" })

-- ─── Zig ───────────────────────────────────────────────────────────
map.set('n', '<Leader>;', 'A;<Esc>', {desc = "Append semicolon to end of a line"})
