return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "windwp/nvim-ts-autotag",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            auto_install   = false,
            sync_install   = false,
            ignore_install = {},
            modules        = {},
            highlight  = { enable = true },
            indent     = { enable = true },
            autotag    = { enable = true },
            ensure_installed = {
                "bash", "c", "css", "dockerfile", "graphql",
                "html", "htmldjango", "json", "lua", "markdown", "markdown_inline",
                "nu", "python", "query", "sql", "vim", "vimdoc", "yaml", "zig",
            },
            incremental_selection = { enable = true, keymaps = {} },
            textobjects = {
                move = {
                    enable = true, set_jumps = false,
                    goto_next_start     = { ["]b"] = { query = "@code_cell.inner", desc = "TS: Next code block" }, ["<M-PageDown>"] = { query = "@code_cell.inner" } },
                    goto_previous_start = { ["[b"] = { query = "@code_cell.inner", desc = "TS: Prev code block" }, ["<M-PageUp>"]   = { query = "@code_cell.inner" } },
                },
                select = {
                    enable = true, lookahead = true,
                    keymaps = {
                        ["ib"] = { query = "@code_cell.inner", desc = "TS: in code block" },
                        ["ab"] = { query = "@code_cell.outer", desc = "TS: around code block" },
                        ["af"] = { query = "@function.outer" },
                        ["if"] = { query = "@function.inner" },
                        ["ac"] = { query = "@class.outer" },
                        ["ic"] = { query = "@class.inner" },
                    },
                },
            },
        })
    end,
}
