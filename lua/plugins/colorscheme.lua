local default = "catppuccin"

return {
    {
        'folke/tokyonight.nvim',
        lazy = default ~= 'tokyonight',
        priority = 1000,
        config = function()
            require('tokyonight').setup({
                style = "storm", transparent = false, terminal_colors = true,
                styles = { floats = "transparent" },
            })
            if default == "tokyonight" then vim.cmd([[colorscheme tokyonight]]) end
        end,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = default ~= 'rose-pine',
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                variant = "auto", dark_variant = "main",
                dim_inactive_windows = false, extend_background_behind_borders = true,
                enable = { terminal = true, legacy_highlights = true, migrations = true },
                styles = { bold = true, italic = true, transparency = false },
            })
            if default == "rose-pine" then vim.cmd([[colorscheme rose-pine]]) end
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = default ~= 'catppuccin',
        priority = 1000,
        config = function()
            require('catppuccin').setup({
                flavour = "mocha",
                background = { light = "latte", dark = "mocha" },
                transparent_background = false,
                term_colors = true,
                styles = { comments = { "italic" }, conditionals = { "italic" } },
                default_integrations = true,
                integrations = { gitsigns = true, treesitter = true, mini = { enabled = true } },
            })
            if default == "catppuccin" then vim.cmd([[colorscheme catppuccin]]) end
        end,
    },
    {
        'rebelot/kanagawa.nvim',
        lazy = default ~= 'kanagawa',
        priority = 1000,
        config = function()
            require('kanagawa').setup({
                compile = false, undercurl = true,
                commentStyle = { italic = true }, keywordStyle = { italic = true },
                statementStyle = { bold = true }, transparent = false,
                terminalColors = true, theme = "wave",
                background = { dark = "wave", light = "lotus" },
            })
            if default == "kanagawa" then vim.cmd([[colorscheme kanagawa]]) end
        end,
    },
}
