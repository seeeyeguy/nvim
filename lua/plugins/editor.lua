return {
    -- ─── Autopairs ───────────────────────────────────────────────────────────
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true,
    },

    -- ─── Surround ────────────────────────────────────────────────────────────
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function() require("nvim-surround").setup() end,
    },

    -- ─── Flash: fast motion ───────────────────────────────────────────────────
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            labels = "asdfghjklqwertyuiopzxcvbnm",
            search = {
                multi_window = true, forward = true, wrap = true, mode = "exact",
                incremental = false,
                exclude = {
                    "notify", "cmp_menu", "noice", "flash_prompt",
                    function(win) return not vim.api.nvim_win_get_config(win).focusable end,
                },
                trigger = "", max_length = false,
            },
            jump  = { jumplist = true, pos = "start", history = false, register = false, nohlsearch = false, autojump = false },
            label = { uppercase = true, current = true, after = true, before = false, style = "overlay", reuse = "lowercase", distance = true, min_pattern_length = 0 },
            highlight = { backdrop = true, matches = true, priority = 5000 },
            modes = {
                search = {
                    enabled = true, highlight = { backdrop = false },
                    jump = { history = true, register = true, nohlsearch = true },
                },
                char = {
                    enabled = true,
                    config = function(opts)
                        opts.autohide    = opts.autohide or (vim.fn.mode(true):find("no") and vim.v.operator == "y")
                        opts.jump_labels = opts.jump_labels and vim.v.count == 0 and vim.fn.reg_executing() == "" and vim.fn.reg_recording() == ""
                    end,
                    autohide = false, jump_labels = false, multi_line = true,
                    label = { exclude = "hjkliardc" },
                    keys  = { "f", "F", "t", "T", ";", "," },
                    char_actions = function(motion)
                        return { [";"] = "next", [","] = "prev", [motion:lower()] = "next", [motion:upper()] = "prev" }
                    end,
                    search = { wrap = false }, highlight = { backdrop = true },
                    jump = { register = false, autojump = false },
                },
                treesitter = {
                    labels = "abcdefghijklmnopqrstuvwxyz",
                    jump = { pos = "range", autojump = true }, search = { incremental = false },
                    label = { before = true, after = true, style = "inline" },
                    highlight = { backdrop = false, matches = false },
                },
                treesitter_search = {
                    jump = { pos = "range" }, search = { multi_window = true, wrap = true, incremental = false },
                    remote_op = { restore = true }, label = { before = true, after = true, style = "inline" },
                },
                remote = { remote_op = { restore = true, motion = true } },
            },
            prompt = {
                enabled = true, prefix = { { "⚡", "FlashPromptIcon" } },
                win_config = { relative = "editor", width = 1, height = 1, row = -1, col = 0, zindex = 1000 },
            },
            remote_op = { restore = false, motion = false },
        },
        keys = {
            { "gs",    mode = { "n", "x", "o" }, function() require("flash").jump()             end, desc = "Flash" },
            { "gS",    mode = { "n", "x", "o" }, function() require("flash").treesitter()       end, desc = "Flash Treesitter" },
            { "r",     mode = "o",                function() require("flash").remote()           end, desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },       function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" },            function() require("flash").toggle()           end, desc = "Toggle Flash Search" },
        },
    },

    -- ─── Maximizer ───────────────────────────────────────────────────────────
    {
        "szw/vim-maximizer",
        keys = { { "<leader>m", "<cmd>MaximizerToggle<CR>", desc = "Maximize/minimize split" } },
    },

    -- ─── WinShift: window rearranging ────────────────────────────────────────
    {
        'sindrets/winshift.nvim',
        config = function()
            require('winshift').setup({
                highlight_moving_win = true,
                focused_hl_group     = "Visual",
                moving_win_options   = { wrap = false, cursorline = false, cursorcolumn = false, colorcolumn = "" },
                keymaps = {
                    disable_defaults = false,
                    win_move_mode = {
                        ["h"] = "left", ["j"] = "down", ["k"] = "up",   ["l"] = "right",
                        ["H"] = "far_left", ["J"] = "far_down", ["K"] = "far_up", ["L"] = "far_right",
                        ["<left>"] = "left", ["<down>"] = "down", ["<up>"] = "up", ["<right>"] = "right",
                    },
                },
                window_picker = function()
                    return require('winshift.lib').pick_window({
                        picker_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                        filter_rules = { cur_win = true, floats = true, filetype = {}, buftype = {}, bufname = {} },
                    })
                end,
            })
            -- keymaps are defined in core/keymaps.lua under <leader>w*
        end,
    },

    -- ─── Undotree ────────────────────────────────────────────────────────────
    {
        'mbbill/undotree',
        keys = { { "<leader>ut", "<cmd>UndotreeToggle<CR>", desc = "UndoTree: Toggle" } },
        config = function()
            if vim.fn.has("win32") == 1 then
                vim.g.undotree_DiffCommand = vim.fn.stdpath('config') .. "\\bin\\diff.exe"
            end
        end,
    },

    -- ─── Session management ───────────────────────────────────────────────────
    {
        'tpope/vim-obsession',
        config = function()
            local home_dir    = os.getenv("HOME") or os.getenv("USERPROFILE")
            local session_dir = home_dir .. "/.nvim-sessions"
            _G.session_file   = session_dir .. "/session.vim"
            if vim.fn.isdirectory(session_dir) == 0 then vim.fn.mkdir(session_dir, "p") end
            if vim.fn.filereadable(session_file)  == 0 then vim.fn.writefile({}, session_file) end

            local map = vim.keymap
            map.set('n', '<leader>os', ':Obsess ' .. session_file .. '<CR>', { noremap = true, silent = true, desc = "Session: Start saving" })
            map.set('n', '<leader>od', ':Obsess!<CR>',                        { noremap = true, silent = true, desc = "Session: Stop and delete" })
            map.set('n', '<leader>or', ':source ' .. session_file .. '<CR>',  { noremap = true, silent = true, desc = "Session: Restore last" })
        end,
    },

    -- ─── Comment toggling ────────────────────────────────────────────────────
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = true,
    },

    -- ─── TODO / FIXME / NOTE highlights ──────────────────────────────────────
    {
        "folke/todo-comments.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        keys = {
            { "]t", function() require("todo-comments").jump_next() end, desc = "Todo: Next" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Todo: Prev" },
            { "<leader>st", "<cmd>lua Snacks.picker.todo_comments()<cr>",               desc = "Todo: Search all" },
            { "<leader>sT", "<cmd>lua Snacks.picker.todo_comments({ keywords = { 'TODO', 'FIX', 'FIXME' } })<cr>", desc = "Todo: Search TODO/FIX" },
        },
    },

    -- ─── Django support ───────────────────────────────────────────────────────
    {
        "tweekmonster/django-plus.vim",
        ft = { "python", "htmldjango" },
        config = function()
            vim.g.django_disable_modeline  = 1
            vim.g.django_templates         = 1
            vim.g.django_highlight_tags    = 1
        end,
    },
}
