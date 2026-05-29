vim.opt.winbar = "%=%m %f"

local options = {
    termguicolors = true,
    showmode = false,
    autoindent = true,
    smartindent = true,
    shiftwidth = 4,
    number = true,
    relativenumber = true,
    scrolloff = 10,
    cursorline = true,
    linebreak = true,
    hlsearch = false,
    incsearch = true,
    ignorecase = true,
    smartcase = true,
    title = false,
    swapfile = false,
    wildmode = 'longest:full',
    signcolumn = "yes",
}

-- Suppress lspconfig deprecation warnings during plugin ecosystem transition
local notify = vim.notify
vim.notify = function(msg, level, opts)
    if msg:match("lspconfig.*deprecated") then return end
    notify(msg, level, opts)
end

-- NuShell support
if vim.fn.executable('nu') == 1 then
    options.sh = "nu"
    options.shellcmdflag = "--stdin --no-newline -c"
    options.shelltemp = false
    options.shellredir = "out+err> %s"
    options.shellxquote = ""
    options.shellquote = ""
    options.shellxescape = ""
    options.shellpipe = "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"
end

for option, value in pairs(options) do vim.opt[option] = value end

vim.cmd("highlight Normal ctermbg=NONE guibg=NONE")
vim.g.netrw_liststyle = 3
vim.g.markdown_folding = 1
vim.wo.foldlevel = 9999
vim.g.render_ipynb_as_markdown = true
