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
		"html", "htmldjango", "json", "markdown", "markdown_inline",
		"nu", "python", "query", "sql", "vim", "vimdoc", "yaml", "zig",
	    },
	    ignore_install = { "lua" },
	    incremental_selection = { enable = true, keymaps = {} },
	    textobjects = {
		move = {
		    enable = true, set_jumps = true,
		    goto_next_start     = {
			["]b"] = { query = "@code_cell.inner" },
			["<M-PageDown>"] = { query = "@code_cell.inner" },
			["]f"] = { query = "@function.outer", desc = "TS: Next function" },
			["]l"] = { query = "@loop.outer",     desc = "TS: Next loop" },
		    },
		    goto_previous_start = {
			["[b"] = { query = "@code_cell.inner" },
			["<M-PageUp>"] = { query = "@code_cell.inner" },
			["[f"] = { query = "@function.outer", desc = "TS: Prev function" },
			["[l"] = { query = "@loop.outer",     desc = "TS: Prev loop" },
		    },
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
			["aa"] = { query = "@parameter.outer" },   -- 'a' for argument
			["ia"] = { query = "@parameter.inner" },
			["ai"] = { query = "@conditional.outer" },
			["ii"] = { query = "@conditional.inner" },
			["al"] = { query = "@loop.outer" },
			["il"] = { query = "@loop.inner" },
			["ak"] = { query = "@block.outer" },
			["ik"] = { query = "@block.inner" },
			["am"] = { query = "@comment.outer" },
			["im"] = { query = "@comment.outer" },
		    },
		},
	    },
	})
    end,
}
