return {
    {
        name    = 'Python: Current File',
        type    = 'python',
        request = 'launch',
        program = '${file}',
        console = 'integratedTerminal',
        justMyCode = false,
    },
    {
        name    = 'Python: Current File with Args',
        type    = 'python',
        request = 'launch',
        program = '${file}',
        console = 'integratedTerminal',
        args = function()
            return vim.split(vim.fn.input('Arguments: '), " ")
        end,
        justMyCode = false,
    },
    {
        name    = 'Django: Development Server',
        type    = 'python',
        request = 'launch',
        program = vim.fn.getcwd() .. '/manage.py',
        args    = { 'runserver', '--noreload' },
        django  = true,
        console = 'integratedTerminal',
        justMyCode = false,
    },
    {
        name   = 'Flask: Development Server',
        type   = 'python',
        request = 'launch',
        module = 'flask',
        env    = { FLASK_APP = 'app.py', FLASK_DEBUG = '1' },
        args   = { 'run', '--no-debugger', '--no-reload' },
        console = 'integratedTerminal',
        justMyCode = false,
    },
    {
        name    = 'Pytest: Current File',
        type    = 'python',
        request = 'launch',
        module  = 'pytest',
        args    = { '${file}', '-v' },
        console = 'integratedTerminal',
        justMyCode = false,
    },
    {
        name    = 'Pytest: Current Test',
        type    = 'python',
        request = 'launch',
        module  = 'pytest',
        args = function()
            local test_name = vim.fn.input('Test name (empty for all): ')
            return test_name == "" and { '${file}', '-v' } or { '${file}', '-v', '-k', test_name }
        end,
        console = 'integratedTerminal',
        justMyCode = false,
    },
    {
        name    = 'Python: Attach Remote (localhost:5678)',
        type    = 'python',
        request = 'attach',
        connect = { host = 'localhost', port = 5678 },
        pathMappings = { { localRoot = vim.fn.getcwd(), remoteRoot = '.' } },
        justMyCode = false,
    },
    {
        name    = 'Python: Attach Remote (Custom Port)',
        type    = 'python',
        request = 'attach',
        connect = function()
            local host = vim.fn.input('Host (default: localhost): ')
            local port = tonumber(vim.fn.input('Port (default: 5678): '))
            return { host = host ~= "" and host or 'localhost', port = port or 5678 }
        end,
        pathMappings = { { localRoot = vim.fn.getcwd(), remoteRoot = '.' } },
        justMyCode = false,
    },
}
