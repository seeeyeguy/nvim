return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    dependencies = {
        "windwp/nvim-ts-autotag",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    config = function()
        local select = require('nvim-treesitter-textobjects.select')
        local move   = require('nvim-treesitter-textobjects.move')
        local config = require('nvim-treesitter-textobjects.config')

        config.update({
            select = {
                enable = true,
                lookahead = true,
            },
            move = {
                enable = true,
                set_jumps = true,
            },
        })

        -- ── Select keymaps ────────────────────────────────────────────────
        local keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["ai"] = "@conditional.outer",
            ["ii"] = "@conditional.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["ak"] = "@block.outer",
            ["ik"] = "@block.inner",
            ["am"] = "@comment.outer",
            ["im"] = "@comment.outer",
            ["ab"] = "@code_cell.outer",
            ["ib"] = "@code_cell.inner",
        }

        for key, query in pairs(keymaps) do
            vim.keymap.set({ "x", "o" }, key, function()
                select.select_textobject(query, "textobjects")
            end, { desc = "TS: " .. query })
        end

        -- ── Move keymaps ──────────────────────────────────────────────────
        vim.keymap.set("n", "]f", function() move.goto_next_start("@function.outer",  "textobjects") end, { desc = "TS: Next function" })
        vim.keymap.set("n", "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "TS: Prev function" })
        vim.keymap.set("n", "]l", function() move.goto_next_start("@loop.outer",      "textobjects") end, { desc = "TS: Next loop" })
        vim.keymap.set("n", "[l", function() move.goto_previous_start("@loop.outer",  "textobjects") end, { desc = "TS: Prev loop" })
        vim.keymap.set("n", "]b", function() move.goto_next_start("@code_cell.inner", "textobjects") end, { desc = "TS: Next code cell" })
        vim.keymap.set("n", "[b", function() move.goto_previous_start("@code_cell.inner", "textobjects") end, { desc = "TS: Prev code cell" })
    end,
}
