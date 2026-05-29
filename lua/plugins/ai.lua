local customutils  = require("custom.utils")
local laci_pixtral = customutils.safe_require("local.codecompanion.laci_pixtral", {})

return {
    -- ─── GitHub Copilot ───────────────────────────────────────────────────────
    {
        'github/copilot.vim',
        config = function()
            vim.g.copilot_enabled = false
            vim.keymap.set('n', '<leader>cp', function()
                vim.g.copilot_enabled = not vim.g.copilot_enabled
                vim.notify("Copilot " .. (vim.g.copilot_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
            end, { desc = "Copilot: Toggle suggestions" })
        end,
    },

    -- ─── CodeCompanion ───────────────────────────────────────────────────────
    {
        "olimorris/codecompanion.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
        lazy = false,
        opts = {
            adapters = {
                http = {
                    laci_pixtral = function()
                        if not next(laci_pixtral) then return nil end
                        return require("codecompanion.adapters").extend("openai_compatible", {
                            env = {
                                url             = laci_pixtral.config.env.url,
                                api_key         = laci_pixtral.config.env.api_key,
                                chat_url        = laci_pixtral.config.env.chat_url,
                                models_endpoint = laci_pixtral.config.env.models_endpoint,
                            },
                            schema = { model = { default = laci_pixtral.config.schema.model.default } },
                        })
                    end,
                },
            },
            strategies = {
                chat   = { adapter = (next(laci_pixtral) ~= nil and laci_pixtral.enabled) and "laci_pixtral" or "copilot" },
                inline = { adapter = (next(laci_pixtral) ~= nil and laci_pixtral.enabled) and "laci_pixtral" or "copilot" },
            },
            opts = { log_level = "DEBUG" },
        },
        keys = {
            { mode = 'n', "<leader>ai", "<cmd>CodeCompanionChat Toggle<CR>", desc = "CodeCompanion: Open Chat" },
        },
    },
}
