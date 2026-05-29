-- Yank highlight
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

-- Open help/man/markdown buffers as vertical splits
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "help", "man", "markdown" },
    callback = function()
        if vim.bo.buftype ~= "nofile" then vim.cmd("wincmd L") end
    end,
    desc = "Open help/man/markdown as vertical splits",
})

-- Disable diagnostics in help buffers
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "help", "man" },
    callback = function()
        if vim.bo.buftype == "help" then
            vim.diagnostic.enable(false, { bufnr = 0 })
        end
    end,
    desc = "Disable LSP diagnostics in help files",
})

-- shellslash for Jupytext/ipynb files
vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.ipynb",
    callback = function() vim.opt_local.shellslash = true end,
    desc = "Ensure shellslash for Jupytext files",
})

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd('TermOpen', {
    desc = 'Disable line numbers in terminal',
    group = vim.api.nvim_create_augroup('terminal-open', { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
    end,
})
