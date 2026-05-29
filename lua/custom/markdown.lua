local fn  = vim.fn
local map = vim.keymap

local function md_toggle_checkboxes(start_line, end_line)
    local mode = vim.fn.mode()
    if start_line == nil or end_line == nil then
        if mode == 'v' or mode == 'V' or mode == '<C-v>' then
            start_line, end_line = fn.getpos("'<")[2], fn.getpos("'>")[2]
        else
            start_line, end_line = fn.line('.'), fn.line('.')
        end
    end
    for line_num = start_line, end_line do
        local line = fn.getline(line_num)
        if line:find('%[x%]') then
            line = line:gsub('%[x%]', '[ ]')
        elseif line:find('%[ %]') then
            line = line:gsub('%[ %]', '[x]')
        end
        fn.setline(line_num, line)
    end
end

vim.api.nvim_create_user_command("MarkdownToggleCheckBox",
    function(opts) md_toggle_checkboxes(opts.line1, opts.line2) end,
    { desc = "Markdown: Toggle checkboxes", range = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        local opts = { buffer = true, noremap = true, silent = true }
        map.set("v", "<M-m><M-b>", 'c**<C-r>"**<Esc>', vim.tbl_extend("force", opts, { desc = "Markdown: Bold" }))
        map.set("v", "<M-m><M-i>", 'c*<C-r>"*<Esc>',   vim.tbl_extend("force", opts, { desc = "Markdown: Italic" }))
        map.set("v", "<M-m><M-s>", 'c~~<C-r>"~~<Esc>', vim.tbl_extend("force", opts, { desc = "Markdown: Strikethrough" }))
        map.set("v", "<M-m><M-l>", 'c[<C-r>"]()<Esc>F)i', vim.tbl_extend("force", opts, { desc = "Markdown: Link" }))
        map.set({'n','v'}, '<A-m><A-c>', ':MarkdownToggleCheckBox<CR>', vim.tbl_extend("force", opts, { desc = 'Markdown: Toggle checkboxes' }))
        map.set("n", "<M-m><M-q>", "I> <Esc>",     vim.tbl_extend("force", opts, { desc = "Markdown: Quote" }))
        map.set("v", "<M-m><M-q>", ":s/^/> /<CR>", vim.tbl_extend("force", opts, { desc = "Markdown: Quote" }))
        map.set("n", "<M-m><M-o>", "I1. <Esc>",    vim.tbl_extend("force", opts, { desc = "Markdown: Ordered list" }))
        map.set("v", "<M-m><M-o>", ":s/^/1. /<CR>",vim.tbl_extend("force", opts, { desc = "Markdown: Ordered list" }))
        map.set("n", "<M-m><M-u>", "I- <Esc>",     vim.tbl_extend("force", opts, { desc = "Markdown: Unordered list" }))
        map.set("v", "<M-m><M-u>", ":s/^/- /<CR>", vim.tbl_extend("force", opts, { desc = "Markdown: Unordered list" }))
        map.set("n", "<M-m><M-1>", "I# <Esc>",     vim.tbl_extend("force", opts, { desc = "Markdown: H1" }))
        map.set("n", "<M-m><M-2>", "I## <Esc>",    vim.tbl_extend("force", opts, { desc = "Markdown: H2" }))
        map.set("n", "<M-m><M-3>", "I### <Esc>",   vim.tbl_extend("force", opts, { desc = "Markdown: H3" }))
        map.set("n", "<M-m><M-h>", "o---<Esc>",    vim.tbl_extend("force", opts, { desc = "Markdown: Horizontal rule" }))
    end,
})
