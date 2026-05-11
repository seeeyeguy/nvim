return {
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
	-- Compare against the index (staged) by default.
	-- Change to "origin/main" or "origin/develop" to compare against a branch.
	-- base = "origin/main",


	current_line_blame = false,  -- toggle with <leader>gb

	on_attach = function(bufnr)
	    local gs = require("gitsigns")
	    local map = vim.keymap.set

	    -- Navigation between hunks
	    map("n", "]h", function() gs.nav_hunk("next") end,
		{ buffer = bufnr, desc = "Git: Next hunk" })
	    map("n", "[h", function() gs.nav_hunk("prev") end,
		{ buffer = bufnr, desc = "Git: Previous hunk" })

	    -- Actions
	    map("n", "<leader>gs", gs.stage_hunk,
		{ buffer = bufnr, desc = "Git: Stage hunk" })
	    map("n", "<leader>gr", gs.reset_hunk,
		{ buffer = bufnr, desc = "Git: Reset hunk" })
	    map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
		{ buffer = bufnr, desc = "Git: Stage selected lines" })
	    map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
		{ buffer = bufnr, desc = "Git: Reset selected lines" })
	    map("n", "<leader>gu", gs.undo_stage_hunk,
		{ buffer = bufnr, desc = "Git: Undo stage hunk" })
	    map("n", "<leader>gp", gs.preview_hunk,
		{ buffer = bufnr, desc = "Git: Preview hunk inline" })
	    map("n", "<leader>gb", gs.toggle_current_line_blame,
		{ buffer = bufnr, desc = "Git: Toggle line blame" })
	    map("n", "<leader>gd", gs.diffthis,
		{ buffer = bufnr, desc = "Git: Diff against index" })
	    map("n", "<leader>gD", function() gs.diffthis("~") end,
		{ buffer = bufnr, desc = "Git: Diff against last commit" })
	end,
    },
}
