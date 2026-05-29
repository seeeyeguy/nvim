return {
    -- ─── nvim-dap + UI + Python ──────────────────────────────────────────────
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
            'nvim-neotest/nvim-nio',
            'mfussenegger/nvim-dap-python',
            'nvim-telescope/telescope-dap.nvim',
        },
        config = function()
            local dap    = require('dap')
            local dapui  = require('dapui')
            local map    = vim.keymap

            -- ── DAP UI ───────────────────────────────────────────────────────
            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = 'scopes',      size = 0.25 },
                            { id = 'breakpoints', size = 0.25 },
                            { id = 'stacks',      size = 0.25 },
                            { id = 'watches',     size = 0.25 },
                        },
                        size = 40, position = 'left',
                    },
                    {
                        elements = {
                            { id = 'repl',    size = 0.5 },
                            { id = 'console', size = 0.5 },
                        },
                        size = 10, position = 'bottom',
                    },
                },
                controls = {
                    enabled = true, element = "repl",
                    icons = { pause = "", play = "", step_into = "", step_over = "", step_out = "", step_back = "", run_last = "", terminate = "" },
                },
                floating = { border = "rounded", mappings = { close = { "q", "<Esc>" } } },
            })

            -- ── Virtual Text ─────────────────────────────────────────────────
            require('nvim-dap-virtual-text').setup({
                enabled = true, enabled_commands = true,
                highlight_changed_variables = true, highlight_new_as_changed = true,
                show_stop_reason = true, commented = false,
                only_first_definition = true, all_references = false, clear_on_continue = false,
                virt_text_pos = 'eol', all_frames = false,
                display_callback = function(variable, _, _, _, _)
                    local value = variable.value:gsub("%s+", " ")
                    if #value > 50 then value = value:sub(1, 47) .. "..." end
                    return variable.name .. " = " .. value
                end,
            })

            -- ── Signs & Highlights ───────────────────────────────────────────
            vim.fn.sign_define('DapBreakpoint',         { text = '●', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
            vim.fn.sign_define('DapBreakpointCondition',{ text = '◆', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
            vim.fn.sign_define('DapBreakpointRejected', { text = '⊗', texthl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
            vim.fn.sign_define('DapLogPoint',           { text = '◉', texthl = 'DapLogPoint',   numhl = 'DapLogPoint' })
            vim.fn.sign_define('DapStopped',            { text = '→', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = 'DapStopped' })
            vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
            vim.api.nvim_set_hl(0, 'DapLogPoint',   { fg = '#61afef' })
            vim.api.nvim_set_hl(0, 'DapStopped',    { fg = '#98c379' })
            vim.api.nvim_set_hl(0, 'DapStoppedLine',{ bg = '#3d3d00' })

            -- ── Auto-open/close UI ───────────────────────────────────────────
            dap.listeners.after.event_initialized['dapui_config']  = function() dapui.open()  end
            dap.listeners.before.event_terminated['dapui_config']  = function() dapui.close() end
            dap.listeners.before.event_exited['dapui_config']      = function() dapui.close() end

            -- ── Persistent Breakpoints ───────────────────────────────────────
            local breakpoints_file = vim.fn.stdpath('data') .. '/dap-breakpoints.json'

            local function save_breakpoints()
                local bps = {}
                for bufnr, buf_bps in pairs(dap.breakpoints.get() or {}) do
                    if buf_bps and #buf_bps > 0 then bps[bufnr] = buf_bps end
                end
                vim.fn.writefile({ vim.json.encode(bps) }, breakpoints_file)
            end

            local function load_breakpoints()
                if vim.fn.filereadable(breakpoints_file) == 1 then
                    local data = vim.fn.readfile(breakpoints_file)
                    local ok, bps = pcall(vim.json.decode, table.concat(data))
                    if ok and bps then
                        for _, buf_bps in pairs(bps) do
                            for _, bp in ipairs(buf_bps) do
                                dap.set_breakpoint(bp.condition, bp.hit_condition, bp.log_message)
                            end
                        end
                    end
                end
            end

            vim.api.nvim_create_autocmd('VimLeavePre', { callback = save_breakpoints })
            vim.defer_fn(load_breakpoints, 100)

            -- ── Keymaps ──────────────────────────────────────────────────────
            map.set('n', '<F5>',  dap.continue,   { desc = 'DAP: Continue/Start' })
            map.set('n', '<F10>', dap.step_over,  { desc = 'DAP: Step Over' })
            map.set('n', '<F11>', dap.step_into,  { desc = 'DAP: Step Into' })
            map.set('n', '<F12>', dap.step_out,   { desc = 'DAP: Step Out' })

            map.set('n', '<Leader>db', dap.toggle_breakpoint, { desc = 'DAP: Toggle Breakpoint' })
            map.set('n', '<Leader>dB', function()
                vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(c)
                    if c and c ~= "" then dap.set_breakpoint(c) end
                end)
            end, { desc = 'DAP: Conditional Breakpoint' })
            map.set('n', '<Leader>dl', function()
                vim.ui.input({ prompt = 'Log point message: ' }, function(m)
                    if m and m ~= "" then dap.set_breakpoint(nil, nil, m) end
                end)
            end, { desc = 'DAP: Log Point' })
            map.set('n', '<Leader>dX', function()
                dap.clear_breakpoints()
                vim.notify("Cleared all breakpoints", vim.log.levels.INFO)
            end, { desc = 'DAP: Clear All Breakpoints' })

            map.set('n', '<Leader>dc', dap.continue,      { desc = 'DAP: Continue' })
            map.set('n', '<Leader>dr', dap.restart,       { desc = 'DAP: Restart' })
            map.set('n', '<Leader>dt', dap.terminate,     { desc = 'DAP: Terminate' })
            map.set('n', '<Leader>dp', dap.pause,         { desc = 'DAP: Pause' })
            map.set('n', '<Leader>dC', dap.run_to_cursor, { desc = 'DAP: Run to Cursor' })
            map.set('n', '<Leader>dR', dap.run_last,      { desc = 'DAP: Re-run Last' })

            map.set('n', '<Leader>du', dapui.toggle, { desc = 'DAP: Toggle UI' })
            map.set('n', '<Leader>ds', function() dapui.toggle({ layout = 1 }) end, { desc = 'DAP: Toggle Sidebar' })
            map.set('n', '<Leader>dq', function() dapui.toggle({ layout = 2 }) end, { desc = 'DAP: Toggle Console' })

            map.set({'n','v'}, '<Leader>de', function() dapui.eval(nil, { enter = true }) end, { desc = 'DAP: Eval Expression' })
            map.set('n', '<Leader>dh', function() require('dap.ui.widgets').hover() end, { desc = 'DAP: Hover Variables' })
            map.set('n', '<Leader>dw', function()
                vim.ui.input({ prompt = 'Watch expression: ' }, function(expr)
                    if expr and #expr > 0 then require('dapui').elements.watches.add(expr) end
                end)
            end, { desc = 'DAP: Add Watch' })

            -- Float elements
            map.set('n', '<Leader>dF', function() dapui.float_element('repl',        { enter = true, width = 150, height = 30 }) end, { desc = 'DAP: Float REPL' })
            map.set('n', '<Leader>dS', function() dapui.float_element('scopes',      { enter = true }) end, { desc = 'DAP: Float Scopes' })
            map.set('n', '<Leader>dW', function() dapui.float_element('watches',     { enter = true }) end, { desc = 'DAP: Float Watches' })
            map.set('n', '<Leader>dK', function() dapui.float_element('stacks',      { enter = true }) end, { desc = 'DAP: Float Stacks' })
            map.set('n', '<Leader>dO', function() dapui.float_element('console',     { enter = true }) end, { desc = 'DAP: Float Console' })

            map.set('n', '<Leader>dv', ':DapVirtualTextToggle<CR>', { desc = 'DAP: Toggle Virtual Text' })

            -- Smart step into (skip library code)
            local function is_library_file(path)
                return path and (path:match("/site%-packages/") or path:match("/dist%-packages/") or path:match("/lib/python"))
            end
            map.set('n', '<F9>', function()
                local session = dap.session()
                if not session then vim.notify("No active debug session", vim.log.levels.WARN); return end
                dap.step_into()
                vim.defer_fn(function()
                    local frame = session.current_frame
                    if frame and frame.source and is_library_file(frame.source.path) then
                        vim.notify("Skipping library code...", vim.log.levels.INFO)
                        dap.step_out()
                    end
                end, 100)
            end, { desc = 'DAP: Smart Step Into' })

            -- Telescope integration
            local has_telescope, telescope = pcall(require, 'telescope')
            if has_telescope then
                pcall(telescope.load_extension, 'dap')
                map.set('n', '<Leader>dfc', ':Telescope dap configurations<CR>',  { desc = 'DAP: Find Configurations' })
                map.set('n', '<Leader>dfb', ':Telescope dap list_breakpoints<CR>', { desc = 'DAP: Find Breakpoints' })
                map.set('n', '<Leader>dfv', ':Telescope dap variables<CR>',        { desc = 'DAP: Find Variables' })
                map.set('n', '<Leader>dff', ':Telescope dap frames<CR>',           { desc = 'DAP: Find Frames' })
            end

            -- ── Python DAP ───────────────────────────────────────────────────
            local has_dap_python, dap_python = pcall(require, 'dap-python')
            if has_dap_python then
                dap_python.setup('python3')

                local customutils = require("custom.utils")

                local function get_python_project()
                    local cwd      = vim.fn.getcwd():gsub("/$", "")
                    local projects = customutils.safe_require("local.project_picker.projects", {})
                    for _, project in ipairs(projects) do
                        local dir = project.dir:gsub("^~", vim.fn.expand("~")):gsub("/$", "")
                        if cwd == dir or cwd:find(dir .. "/", 1, true) == 1 then
                            return project.name
                        end
                    end
                    return nil
                end

                local function load_python_configs()
                    local project_name = get_python_project()
                    if project_name then
                        local module = project_name:gsub("-", "_")
                        local configs = customutils.safe_require("local.dap_configs." .. module, nil)
                        if configs and type(configs) == "table" and #configs > 0 then
                            vim.notify("Loaded DAP configs for: " .. project_name, vim.log.levels.INFO)
                            return configs
                        end
                    end
                    local default = customutils.safe_require("local.dap_configs.default", nil)
                    if default and #default > 0 then
                        vim.notify("Using default DAP configs", vim.log.levels.INFO)
                        return default
                    end
                    vim.notify("Using hardcoded DAP fallback", vim.log.levels.WARN)
                    return {{ name = 'Python: Current File', type = 'python', request = 'launch', program = '${file}', console = 'integratedTerminal' }}
                end

                dap.configurations.python = load_python_configs()

                vim.api.nvim_create_autocmd("DirChanged", {
                    callback = function()
                        local new_configs = load_python_configs()
                        if #new_configs > 0 then dap.configurations.python = new_configs end
                    end,
                })

                map.set('n', '<Leader>drc', function() dap.configurations.python = load_python_configs() end, { desc = 'DAP: Reload Python Configs' })
                map.set('n', '<Leader>dE',  function() dap.set_exception_breakpoints({"raised","uncaught"}); vim.notify("Breaking on all exceptions") end, { desc = 'DAP Python: Break on all exceptions' })
                map.set('n', '<Leader>dU',  function() dap.set_exception_breakpoints({"uncaught"}); vim.notify("Breaking on uncaught exceptions") end, { desc = 'DAP Python: Break on uncaught only' })
                map.set('n', '<Leader>dtm', function() require('dap-python').test_method() end, { desc = 'DAP Python: Debug test method' })
                map.set('n', '<Leader>dtc', function() require('dap-python').test_class()  end, { desc = 'DAP Python: Debug test class' })
            end
        end,
    },

    -- ─── Lua debugger ────────────────────────────────────────────────────────
    {
        "jbyuki/one-small-step-for-vimkind",
        config = function()
            local dap = require("dap")
            dap.adapters.nlua = function(callback, conf)
                local adapter = { type = "server", host = conf.host or "127.0.0.1", port = conf.port or 8086 }
                if conf.start_neovim then
                    local dap_run = dap.run
                    dap.run = function(c) adapter.port = c.port; adapter.host = c.host end
                    require("osv").run_this()
                    dap.run = dap_run
                end
                callback(adapter)
            end
            dap.configurations.lua = {
                { type = "nlua", request = "attach", name = "Run this file", start_neovim = {} },
                { type = "nlua", request = "attach", name = "Attach to running Neovim (port 8086)", port = 8086 },
            }
        end,
    },
}
