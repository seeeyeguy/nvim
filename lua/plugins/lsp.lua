return {
    -- ─── Mason: LSP/tool installer ───────────────────────────────────────────
    {
        "williamboman/mason.nvim",
        version = 'v1.*',
        dependencies = {
            { "williamboman/mason-lspconfig.nvim", version = 'v1.*' },
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            require("mason").setup({
                ui = {
                    icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
                    border = "rounded",
                },
            })

            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "jsonls", "zls", "gopls", "ts_ls" },
            })

            require("mason-tool-installer").setup({
                ensure_installed = {
                    "prettier", "stylua", "isort", "black",
                    "pylint", "eslint_d", "marksman",
                    "golangci-lint", "goimports",
                },
            })
        end,
    },

    -- ─── blink.cmp: completion ───────────────────────────────────────────────
    {
        'saghen/blink.cmp',
        enabled = true,
        dependencies = 'rafamadriz/friendly-snippets',
        version = 'v0.*',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = {
                ['<C-n>'] = { 'show', 'show_documentation', 'hide_documentation' },
                ['<C-e>'] = { 'hide' },
                ['<C-y>'] = { 'select_and_accept' },
                ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
                ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
                ['<Up>']   = { 'select_prev', 'fallback' },
                ['<Down>'] = { 'select_next', 'fallback' },
                ['<C-k>']  = { 'select_prev', 'fallback' },
                ['<C-j>']  = { 'select_next', 'fallback' },
                ['<C-b>']  = { 'scroll_documentation_up',   'fallback' },
                ['<C-f>']  = { 'scroll_documentation_down', 'fallback' },
            },
            completion = {
                menu = {
                    auto_show = true,
                    border    = 'single',
                },
                ghost_text = { enabled = true },
                documentation = { window = { border = 'single' } },
            },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'mono',
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
                per_filetype = {
                    sql = { 'snippets', 'dadbod', 'buffer' },
                },
                providers = {
                    cmdline = {
                        enabled = function()
                            return vim.fn.getcmdtype() ~= ':' or not vim.fn.getcmdline():find("!")
                        end,
                    },
                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                },
            },
            signature = { enabled = true, window = { border = 'single' } },
            cmdline = {
                enabled = true,
                keymap  = { preset = 'inherit' },
                completion = { menu = { auto_show = true } },
            },
        },
    },

    -- ─── nvim-lspconfig ──────────────────────────────────────────────────────
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            'saghen/blink.cmp',
            {
                "folke/lazydev.nvim",
                ft = "lua",
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
            'folke/snacks.nvim',
        },
        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            local lspconfig    = require("lspconfig")
            local snacks       = require('snacks')
            local map          = vim.keymap

            -- Diagnostics
            vim.diagnostic.config({
                virtual_text  = true,
                virtual_lines = false,
                float = { border = "rounded" },
            })

            map.set("n", "<leader>vt", function()
                vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
            end, { desc = "Toggle diagnostic virtual text" })

            map.set("n", "<leader>vl", function()
                vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines })
            end, { desc = "Toggle diagnostic virtual lines" })

            -- LSP keymaps on attach
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local opts = { buffer = ev.buf, silent = true }

                    opts.desc = "LSP: Go to Definition"
                    map.set('n', "gd", function() snacks.picker.lsp_definitions() end, opts)

                    opts.desc = "LSP: Search References"; opts.nowait = true
                    map.set('n', "gr", function() snacks.picker.lsp_references() end, opts)

                    opts.desc = "LSP: Go to Implementation"
                    map.set('n', "gI", function() snacks.picker.lsp_implementations() end, opts)

                    opts.desc = "LSP: Go to Type Definition"
                    map.set('n', "gy", function() snacks.picker.lsp_type_definitions() end, opts)

                    opts.desc = "LSP: Search Symbols"
                    map.set('n', "<leader>ss", function() snacks.picker.lsp_symbols() end, opts)

                    opts.desc = "LSP: Hover documentation"
                    map.set("n", "K", function() vim.lsp.buf.hover({ border = 'rounded' }) end, opts)

                    opts.desc = "LSP: Go to declaration"
                    map.set("n", "gD", vim.lsp.buf.declaration, opts)

                    opts.desc = "LSP: Code actions"
                    map.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

                    opts.desc = "LSP: Next diagnostic"
                    map.set("n", "]d", vim.diagnostic.goto_next, opts)

                    opts.desc = "LSP: Prev diagnostic"
                    map.set("n", "[d", vim.diagnostic.goto_prev, opts)

                    opts.desc = "LSP: Smart rename"
                    map.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

                    opts.desc = "LSP: Restart"
                    map.set("n", "<leader>rs", ":LspRestart<CR>", opts)

                    opts.desc = "LSP: Toggle inlay hints"
                    map.set("n", "<leader>ih", function()
                        local clients = vim.lsp.get_clients({ bufnr = 0 })
                        for _, client in ipairs(clients) do
                            if client.supports_method("textDocument/inlayHint") then
                                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                                return
                            end
                        end
                        vim.notify("Inlay hints not supported", vim.log.levels.WARN)
                    end, opts)
                end,
            })

            -- LSP progress spinner
            vim.api.nvim_create_autocmd("LspProgress", {
                callback = function(ev)
                    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
                    vim.notify(vim.lsp.status(), "info", {
                        id    = "lsp_progress",
                        title = "LSP Progress",
                        opts  = function(notif)
                            notif.icon = ev.data.params.value.kind == "end" and " "
                                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                        end,
                    })
                end,
            })

            -- JSON
            lspconfig.jsonls.setup({
                cmd      = { "vscode-json-language-server", "--stdio" },
                filetypes = { "json", "jsonc" },
                init_options = { provideFormatter = true },
                single_file_support = true,
            })

            -- Lua
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime     = { version = 'LuaJIT', path = vim.split(package.path, ';') },
                        diagnostics = { globals = { "vim" } },
                        workspace   = { library = vim.api.nvim_get_runtime_file('', true), checkThirdParty = false },
                        completion  = { callSnippet = "Replace" },
                        hint        = { enable = true },
                        type        = { enable = true },
                    },
                },
            })

            -- Python
            lspconfig.pyright.setup({
                cmd = { vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver", "--stdio" },
                capabilities = capabilities,
                single_file_support = true,
                root_dir = function(fname)
                    local startpath = vim.fs.dirname(fname)
                    local git_root  = vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])
                    return git_root or startpath
                end,
                on_new_config = function(config, root_dir)
                    local function find_python_path()
                        local venv = os.getenv("VIRTUAL_ENV")
                        if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
                            return venv .. "/bin/python"
                        end
                        if root_dir then
                            for _, path in ipairs({
                                root_dir .. "/api/.venv/bin/python",
                                root_dir .. "/api/venv/bin/python",
                                root_dir .. "/.venv/bin/python",
                                root_dir .. "/venv/bin/python",
                                root_dir .. "/env/bin/python",
                            }) do
                                if vim.fn.executable(path) == 1 then return path end
                            end
                        end
                        return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python3"
                    end
                    local python_path = find_python_path()
                    config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
                        python = {
                            pythonPath = python_path,
                            analysis   = { diagnosticMode = "openFilesOnly", autoImportCompletions = true },
                        },
                        pyright = { disableOrganizeImports = true },
                    })
                end,
                settings = {
                    pyright = { disableOrganizeImports = true },
                    python  = {
                        analysis = { diagnosticMode = "openFilesOnly", autoImportCompletions = true },
                        pythonPath = "python3",
                    },
                },
            })

            -- Markdown
            lspconfig.marksman.setup({
                filetypes = { "markdown", "md" },
                capabilities = capabilities,
                root_dir = function(fname)
                    local startpath = vim.fs.dirname(fname)
                    local git_root  = vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])
                    return git_root or startpath
                end,
            })

            -- Go
            lspconfig.gopls.setup({
                capabilities = capabilities,
                settings = {
                    gopls = {
                        analyses  = { unusedparams = true, shadow = true },
                        staticcheck = true,
                        gofumpt   = true,
                        hints = {
                            assignVariableTypes    = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes  = true,
                            constantValues         = true,
                            functionTypeParameters = true,
                            parameterNames         = true,
                            rangeVariableTypes     = true,
                        },
                    },
                },
            })

            -- TypeScript / JavaScript
            lspconfig.ts_ls.setup({
                capabilities = capabilities,
                settings = {
                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints         = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints          = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints  = true,
                            includeInlayEnumMemberValueHints          = true,
                        },
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayParameterNameHints         = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints          = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints  = true,
                            includeInlayEnumMemberValueHints          = true,
                        },
                    },
                },
            })

            -- Zig
            lspconfig.zls.setup({ capabilities = capabilities })
        end,
    },
}
