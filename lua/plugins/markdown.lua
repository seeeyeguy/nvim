local function get_build_cmd()
    if vim.o.shell == "nu" then
        return "cd app; npm install"
    elseif vim.loop.os_uname().version:match("Windows") then
        return "cd app & npm install"
    else
        return "cd app && npm install"
    end
end

return {
    -- ─── Markdown preview in browser ─────────────────────────────────────────
    {
        "iamcco/markdown-preview.nvim",
        cmd   = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft    = { "markdown" },
        build = get_build_cmd(),
        config = function()
            vim.g.mkdp_auto_start = 0
            vim.g.mkdp_auto_close = 1
            vim.g.mkdp_theme      = "dark"
            vim.keymap.set('n', '<A-m><A-p>', ':MarkdownPreviewToggle<CR>',
                { noremap = true, silent = true, desc = "Markdown: Toggle preview" })
        end,
    },

    -- ─── Rendered markdown in Neovim ─────────────────────────────────────────
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('render-markdown').setup({
                render_modes        = true,
                file_types          = { 'markdown', 'codecompanion' },
                restart_highlighter = true,
                code = {
                    enabled = true, render_modes = true, sign = false,
                    style = 'full', position = 'left', language_pad = 0,
                    language_icon = true, language_name = false,
                    disable_background = { 'diff' }, width = 'full',
                    left_margin = 0, left_pad = 0, right_pad = 0, min_width = 0,
                    border = 'thick', above = '▄', below = '▀',
                    inline_left = '', inline_right = '', inline_pad = 0,
                    highlight = 'RenderMarkdownCode',
                    highlight_border = 'RenderMarkdownCodeBorder',
                    highlight_fallback = 'RenderMarkdownCodeFallback',
                    highlight_inline = 'RenderMarkdownCodeInline',
                },
                heading = { backgrounds = {} },
                overrides = {
                    filetype = {
                        codecompanion = {
                            html = {
                                tag = {
                                    buf     = { icon = " ",  highlight = "CodeCompanionChatIcon" },
                                    file    = { icon = " ",  highlight = "CodeCompanionChatIcon" },
                                    group   = { icon = " ",  highlight = "CodeCompanionChatIcon" },
                                    help    = { icon = "󰘥 ", highlight = "CodeCompanionChatIcon" },
                                    image   = { icon = " ",  highlight = "CodeCompanionChatIcon" },
                                    symbols = { icon = " ",  highlight = "CodeCompanionChatIcon" },
                                    tool    = { icon = "󰯠 ", highlight = "CodeCompanionChatIcon" },
                                    url     = { icon = "󰌹 ", highlight = "CodeCompanionChatIcon" },
                                },
                            },
                        },
                    },
                },
            })
            vim.keymap.set('n', '<A-m><A-r>', ':RenderMarkdown toggle<CR>',
                { noremap = true, silent = true, desc = 'Markdown: Toggle render' })
        end,
    },
}
