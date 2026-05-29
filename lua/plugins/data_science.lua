return {
    -- ─── Jupytext: edit notebooks as markdown ─────────────────────────────────
    {
        "GCBallesteros/jupytext.nvim",
        lazy = false,
        config = function()
            local render_as_md = vim.g.render_ipynb_as_markdown
            if render_as_md == nil then render_as_md = true end

            require('jupytext').setup(render_as_md and {
                style = "markdown", output_extension = "md", force_ft = "markdown",
            } or {})

            vim.api.nvim_create_user_command("JupytextToggleMarkdown", function()
                vim.g.render_ipynb_as_markdown = not vim.g.render_ipynb_as_markdown
                vim.cmd("Lazy reload jupytext.nvim")
                vim.notify("Render as markdown: " .. tostring(vim.g.render_ipynb_as_markdown))
            end, {})

            vim.api.nvim_create_user_command("JupytextExportAsPy", function()
                local filename    = vim.fn.expand("%:t")
                local fullpath    = vim.fn.expand("%:p")
                local stderr_out  = {}
                vim.fn.jobstart({ "jupytext", "--to", "py:percent", fullpath }, {
                    stdout_buffered = true, stderr_buffered = true,
                    on_stderr = function(_, data)
                        for _, line in ipairs(data) do
                            if line ~= "" then table.insert(stderr_out, line) end
                        end
                    end,
                    on_exit = function(_, code)
                        if code == 0 then
                            vim.notify("✅ Exported '" .. filename .. "' to Python", vim.log.levels.INFO)
                        else
                            vim.notify("❌ Failed to export '" .. filename .. "'\n" .. table.concat(stderr_out, "\n"), vim.log.levels.ERROR)
                        end
                    end,
                })
            end, {})
        end,
    },

    -- ─── Quarto: literate programming ────────────────────────────────────────
    {
        "quarto-dev/quarto-nvim",
        dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter" },
        ft = { "quarto", "markdown", "python" },
        config = function()
            local quarto = require("quarto")
            quarto.setup({
                lspFeatures = {
                    languages = { "python", "lua" }, chunks = "all",
                    diagnostics = { enabled = true, triggers = { "BufWritePost" } },
                    completion   = { enabled = true },
                },
                keymap     = { hover = "K", definition = "gd", rename = "<leader>rn", references = "gr", format = "<leader>gf" },
                codeRunner = { enabled = true, default_method = "molten" },
            })

            local runner = require("quarto.runner")

            local function set_search_term()
                local ext      = vim.fn.bufname():match('^.+%.([^.]+)')
                local cell_tag = ({ ipynb = '```python' })[ext] or "No Match"
                vim.cmd(":let @/ = '" .. cell_tag .. "'")
            end

            local function setup_quarto_keymaps(bufnr)
                local function kmap(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true, buffer = bufnr }) end
                kmap("<leader>xc", function() runner.run_cell();  set_search_term() end,                      "Quarto: Run cell")
                kmap("<C-CR>",     function() runner.run_cell();  set_search_term() end,                      "Quarto: Run cell")
                kmap("<leader>xb", function() runner.run_cell();  set_search_term(); vim.cmd("normal ]b") end,"Quarto: Run cell and goto next")
                kmap("<S-CR>",     function() runner.run_cell();  set_search_term(); vim.cmd("normal ]b") end,"Quarto: Run cell and goto next")
                kmap("<leader>xu", function() runner.run_above(); set_search_term() end,                      "Quarto: Run cell and above")
                kmap("<leader>xa", function() runner.run_all();   set_search_term() end,                      "Quarto: Run all cells")
                kmap("<leader>xl", function() runner.run_line();  set_search_term() end,                      "Quarto: Run line")
                kmap("<leader>XA", function() runner.run_all(true); set_search_term() end,                    "Quarto: Run all cells (all languages)")
            end

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
                group   = vim.api.nvim_create_augroup("QuartoKeymaps", { clear = true }),
                pattern = { "*.qmd", "*.md", "*.ipynb" },
                callback = function(args)
                    local clients = vim.lsp.get_clients({ bufnr = args.buf, name = 'otter-ls[' .. args.buf .. ']' })
                    if #clients > 0 then setup_quarto_keymaps(args.buf) end
                end,
            })
        end,
    },

    -- ─── vim-slime: send code to REPL ────────────────────────────────────────
    {
        "jpalardy/vim-slime",
        init = function()
            vim.g.slime_target     = "neovim"
            vim.g.slime_no_mappings = true
        end,
        config = function()
            vim.g.slime_input_pid             = false
            vim.g.slime_suggest_default       = true
            vim.g.slime_menu_config           = false
            vim.g.slime_neovim_ignore_unlisted = false
            vim.keymap.set("n", "gz",  "<Plug>SlimeMotionSend", { remap = true, desc = "Slime: Send motion" })
            vim.keymap.set("n", "gzz", "<Plug>SlimeLineSend",   { remap = true, desc = "Slime: Send line" })
            vim.keymap.set("x", "gz",  "<Plug>SlimeRegionSend", { remap = true, desc = "Slime: Send region" })
            vim.keymap.set("n", "gzc", "<Plug>SlimeConfig",     { remap = true, desc = "Slime: Config" })
        end,
    },
}
