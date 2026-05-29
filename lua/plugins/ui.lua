local customutils = require("custom.utils")

return {
    -- ─── Alpha: dashboard ────────────────────────────────────────────────────
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha     = require("alpha")
            local dashboard = require("alpha.themes.dashboard")
            local greeting  = customutils.safe_require("local.alpha.greeting", "Welcome to Neovim!")
            local messages  = customutils.safe_require("local.alpha.messages", {{ message = "Make it a great day." }})

            local function load_random_message()
                if #messages == 0 then return "" end
                return messages[vim.fn.rand() % #messages + 1].message
            end

            dashboard.section.header.val = {
                [[                                                                       ]],
                [[                                                                     ]],
                [[       ████ ██████           █████      ██                     ]],
                [[      ███████████             █████                             ]],
                [[      █████████ ███████████████████ ███   ███████████   ]],
                [[     █████████  ███    █████████████ █████ ██████████████   ]],
                [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
                [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
                [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
            }

            dashboard.section.buttons.val = {
                dashboard.button("o", "  Open last session",   ":source ~/.nvim-sessions/session.vim<CR>"),
                dashboard.button("n", "  New file",            ":enew<CR>"),
                dashboard.button("f", "󰈞  Find file",          ":lua Snacks.picker.files()<CR>"),
                dashboard.button("r", "󰈢  Recent files",       ":lua Snacks.picker.recent()<CR>"),
                dashboard.button("e", "  Open explorer",       ":lua require('mini.files').open()<CR>"),
                dashboard.button("h", "  Help search",         ":lua Snacks.picker.help()<CR>"),
                dashboard.button("t", "  Open todos",          ":MarkdownUpdateTodos<CR>"),
                dashboard.button("c", "  Config files",        ":lua Snacks.picker.files({ cwd= vim.fn.stdpath('config') })<CR>"),
                dashboard.button(".", "  Commands",            ":lua Snacks.picker.commands()<CR>"),
                dashboard.button("?", "  Keymaps",             ":lua Snacks.picker.keymaps()<CR>"),
                dashboard.button("u", "  Colorscheme",         ":lua Snacks.picker.colorschemes()<CR>"),
                dashboard.button("l", "󰒲  Lazy",               ":Lazy<CR>"),
                dashboard.button("m", "󱌢  Mason",              ":Mason<CR>"),
                dashboard.button("q", "󰩈  Quit",               ":qa<CR>"),
            }

            vim.keymap.set('n', '<A-a>', ':Alpha<CR>', { noremap = true, silent = true, desc = 'Alpha: Open dashboard' })
            alpha.setup(dashboard.config)

            vim.api.nvim_create_autocmd("User", {
                once = true, pattern = "LazyVimStarted",
                callback = function()
                    local stats = require("lazy").stats()
                    local ms    = math.floor(stats.startuptime * 100 + 0.5) / 100
                    local footer_lines = { "", greeting, load_random_message(), "",
                        "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }

                    local function center_lines(lines)
                        local max_w = 0
                        for _, l in ipairs(lines) do max_w = math.max(max_w, vim.fn.strdisplaywidth(l)) end
                        local out = {}
                        for _, l in ipairs(lines) do
                            local pad = math.floor((max_w - vim.fn.strdisplaywidth(l)) / 2)
                            table.insert(out, string.rep(" ", pad) .. l)
                        end
                        return out
                    end

                    dashboard.section.footer.val = center_lines(footer_lines)
                    pcall(vim.cmd.AlphaRedraw)
                    dashboard.section.footer.opts.hl = "AlphaFooter"
                end,
            })
        end,
    },

    -- ─── Bufferline ──────────────────────────────────────────────────────────
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require('bufferline').setup({
                options = {
                    mode = "buffers",
                    always_show_bufferline  = false,
                    auto_toggle_bufferline  = false,
                },
            })
        end,
    },

    -- ─── Lualine ─────────────────────────────────────────────────────────────
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    disabled_filetypes = {
                        statusline = { 'alpha', 'dashboard', "snacks_dashboard" },
                    },
                    ignore_focus = {
                        'dap-repl', 'dapui_console', 'dapui_scopes',
                        'dapui_breakpoints', 'dapui_stacks', 'dapui_watches',
                    },
                    sections = {
                        lualine_a = { 'mode' },
                        lualine_b = { 'branch', 'diff' },
                        lualine_c = { { 'filename', path = 2 } },
                    },
                },
            })
        end,
    },
}
