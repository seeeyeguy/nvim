return {
    -- ─── Gitsigns ────────────────────────────────────────────────────────────
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "▁" },
                topdelete    = { text = "▔" },
                changedelete = { text = "▎" },
                untracked    = { text = "┆" },
            },
            current_line_blame = false,
            on_attach = function(bufnr)
                local gs  = require("gitsigns")
                local map = vim.keymap.set

		map("n", "]h", function() gs.nav_hunk("next", { wrap = true }) end, { buffer = bufnr, desc = "Git: Next hunk" })
		map("n", "[h", function() gs.nav_hunk("prev", { wrap = true }) end, { buffer = bufnr, desc = "Git: Prev hunk" })
		map("n", "<leader>gts", function() gs.toggle_signs() end, { buffer = bufnr, desc = "Git: Toggle staged hunks" })

                map("n", "<leader>gs", gs.stage_hunk,                       { buffer = bufnr, desc = "Git: Stage hunk" })
                map("n", "<leader>gr", gs.reset_hunk,                       { buffer = bufnr, desc = "Git: Reset hunk" })
                map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Git: Stage selected lines" })
                map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Git: Reset selected lines" })
                map("n", "<leader>gu", gs.undo_stage_hunk,                  { buffer = bufnr, desc = "Git: Undo stage hunk" })
                map("n", "<leader>gp", gs.preview_hunk,                     { buffer = bufnr, desc = "Git: Preview hunk" })
                map("n", "<leader>gb", gs.toggle_current_line_blame,        { buffer = bufnr, desc = "Git: Toggle line blame" })
                map("n", "<leader>gd", gs.diffthis,                         { buffer = bufnr, desc = "Git: Diff against index" })
                map("n", "<leader>gD", function() gs.diffthis("~") end,     { buffer = bufnr, desc = "Git: Diff against last commit" })
            end,
        },
    },

    -- ─── Diffview ────────────────────────────────────────────────────────────
    {
        'sindrets/diffview.nvim',
        version = false,
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = {},
    },

    -- ─── Lazygit ─────────────────────────────────────────────────────────────
    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd  = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { mode = 'n', "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
    },
}
