-- Default Python debug configurations
-- These are used when no project-specific config is found

return {
    -- Standard Python file debugging
    {
        name = 'Python: Current File',
        type = 'python',
        request = 'launch',
        program = '${file}',
        console = 'integratedTerminal',
        justMyCode = false,
    },
    

    -- Debug with arguments
    {
        name = 'Python: Current File with Args',
        type = 'python',
        request = 'launch',
        program = '${file}',
        console = 'integratedTerminal',
        args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " ")
        end,
        justMyCode = false,
    },

    -- Django development server
    {
        name = 'Django: Development Server',
        type = 'python',
        request = 'launch',
        program = vim.fn.getcwd() .. '/manage.py',
        args = { 'runserver', '--noreload' },
        django = true,
        console = 'integratedTerminal',
        justMyCode = false,
    },

    -- Flask application

    {
        name = 'Flask: Development Server',
        type = 'python',
        request = 'launch',
        module = 'flask',
        env = {
            FLASK_APP = 'app.py',
            FLASK_DEBUG = '1',
        },
        args = { 'run', '--no-debugger', '--no-reload' },

        console = 'integratedTerminal',
        justMyCode = false,
    },

    -- Pytest
    {
        name = 'Pytest: Current File',
        type = 'python',
        request = 'launch',
        module = 'pytest',
        args = { '${file}', '-v' },

        console = 'integratedTerminal',
        justMyCode = false,
    },

    -- Pytest with specific test
    {
        name = 'Pytest: Current Test',
        type = 'python',
        request = 'launch',
        module = 'pytest',
        args = function()
            local test_name = vim.fn.input('Test name (leave empty for all): ')
            if test_name == "" then
                return { '${file}', '-v' }
            else
                return { '${file}', '-v', '-k', test_name }
            end
        end,
        console = 'integratedTerminal',
        justMyCode = false,
    },

    -- Remote debugger (attach)
    {

        name = 'Python: Attach Remote (localhost:5678)',
        type = 'python',
        request = 'attach',
        connect = {
            host = 'localhost',
            port = 5678,
        },
        pathMappings = {
            {
                localRoot = vim.fn.getcwd(),
                remoteRoot = '.',
            },
        },
        justMyCode = false,
    },

    -- Remote debugger with custom port
    {
        name = 'Python: Attach Remote (Custom Port)',
        type = 'python',
        request = 'attach',
        connect = function()
            local host = vim.fn.input('Host (default: localhost): ')
            if host == "" then host = 'localhost' end
            
            local port = tonumber(vim.fn.input('Port (default: 5678): '))
            if not port then port = 5678 end
            
            return { host = host, port = port }
        end,
        pathMappings = {
            {

                localRoot = vim.fn.getcwd(),
-- Example nvim-dap configuration for debugging Django with debugpy
-- Add this to your Neovim configuration (e.g., ~/.config/nvim/lua/plugins/dap.lua)

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      local dap_python = require('dap-python')

      -- Setup Python debugging (adjust python path if needed)
      dap_python.setup('python3')


      -- Configure debugpy for remote Django containers
      dap.configurations.python = {
        {

          name = 'Django API (Remote - port 5678)',
          type = 'python',
          request = 'attach',
          connect = {
            host = 'localhost',
            port = 5678,
          },

          mode = 'remote',
          pathMappings = {
            {
              localRoot = vim.fn.getcwd() .. '/api/src',  -- Adjust to your project structure
              remoteRoot = '/apps/bi-portal',
            },
          },
          django = true,
          justMyCode = false,  -- Set to true to only debug your code
        },
        {

          name = 'RQ Scheduler (Remote - port 5679)',
          type = 'python',
          request = 'attach',
          connect = {
            host = 'localhost',
            port = 5679,
          },
          mode = 'remote',
          pathMappings = {
            {
              localRoot = vim.fn.getcwd() .. '/src',
              remoteRoot = '/apps/bi-portal',
            },
          },
          justMyCode = false,
        },
        {
          name = 'RQ Worker 1 (Remote - port 5680)',
          type = 'python',
          request = 'attach',
          connect = {
            host = 'localhost',
            port = 5680,
          },
          mode = 'remote',
          pathMappings = {
            {
              localRoot = vim.fn.getcwd() .. '/src',
              remoteRoot = '/apps/bi-portal',
            },
          },
          justMyCode = false,
        },
      }

      -- DAP UI setup
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = 'scopes', size = 0.25 },
              { id = 'breakpoints', size = 0.25 },
              { id = 'stacks', size = 0.25 },
              { id = 'watches', size = 0.25 },
            },
            size = 40,
            position = 'left',
          },
          {
            elements = {
              { id = 'repl', size = 0.5 },
              { id = 'console', size = 0.5 },
            },
            size = 10,
            position = 'bottom',
          },
        },
      })

      -- Virtual text setup (shows variable values inline)
      require('nvim-dap-virtual-text').setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
      })

      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()

      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      -- Key mappings
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'DAP: Continue' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'DAP: Step Over' })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'DAP: Step Into' })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'DAP: Step Out' })
      vim.keymap.set('n', '<Leader>db', dap.toggle_breakpoint, { desc = 'DAP: Toggle Breakpoint' })
      vim.keymap.set('n', '<Leader>dB', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { desc = 'DAP: Conditional Breakpoint' })
      vim.keymap.set('n', '<Leader>dr', dap.repl.open, { desc = 'DAP: Open REPL' })

      vim.keymap.set('n', '<Leader>dl', dap.run_last, { desc = 'DAP: Run Last' })
      vim.keymap.set('n', '<Leader>dt', dap.terminate, { desc = 'DAP: Terminate' })
      vim.keymap.set('n', '<Leader>du', dapui.toggle, { desc = 'DAP: Toggle UI' })

      -- Telescope integration (if you use Telescope)
      local has_telescope, telescope = pcall(require, 'telescope')
      if has_telescope then
        telescope.load_extension('dap')
        vim.keymap.set('n', '<Leader>dc', ':Telescope dap configurations<CR>', { desc = 'DAP: Select Configuration' })
        vim.keymap.set('n', '<Leader>dv', ':Telescope dap variables<CR>', { desc = 'DAP: View Variables' })
      end
    end,
  },
}
                remoteRoot = '.',
            },
        },
        justMyCode = false,
    },
}
