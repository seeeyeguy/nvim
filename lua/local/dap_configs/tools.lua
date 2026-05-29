return {
    {
        name = 'Python: Launch File',
        type = 'python',
        request = 'launch',
	program = '${file}',
	justMyCode = false,
	console = 'integratedTerminal'
    },
    {
        name = 'Python: Launch with args',
        type = 'python',
        request = 'launch',
	program = '${file}',
	args = function()
            local args = vim.fn.input("Args: ")
            return vim.split(args, " ")
        end,
	justMyCode = false,
	console = 'integratedTerminal'
    },
    {
        name = "Python: Module",
        type = "python",
        request = "launch",
        module = function()
            return vim.fn.input("Module: ")
        end,
        justMyCode = false,
        console = "integratedTerminal",
    },
}

