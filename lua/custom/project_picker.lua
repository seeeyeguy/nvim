local customutils = require("custom.utils")
local projects    = customutils.safe_require("local.project_picker.projects", nil)

local M = {}

function M.project_picker()
    if projects == nil then
        vim.notify(
            "*projects.lua not found.*\n\nCreate at nvim/lua/local/project_picker/projects.lua\n\nExample:\nreturn {\n    { name = 'myproject', dir = '~/myproject' },\n}",
            vim.log.levels.WARN,
            { title = "Projects", timeout = 5000 }
        )
        return
    end

    local items = {}
    for _, p in ipairs(projects) do
        table.insert(items, { text = p.name, project = p })
    end

    Snacks.picker.pick({
        source  = "Projects",
        items   = items,
        preview = "none",
        layout  = { preset = "select" },
        format  = "text",
        confirm = function(picker, item)
            picker:close()
            vim.api.nvim_set_current_dir(item.project.dir)
            vim.notify("Working directory: " .. item.project.name, vim.log.levels.INFO, { title = "Projects" })
        end,
    })
end

return M
