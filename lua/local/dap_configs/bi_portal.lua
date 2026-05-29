-- Debug configurations for your Django/RQ project
-- Replace this filename with your actual project name from projects.lua

return {
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
                localRoot = vim.fn.getcwd() .. '/api/src',
                remoteRoot = '/apps/bi-portal',
            },
        },
        django = true,
        justMyCode = false,
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
                localRoot = vim.fn.getcwd() .. '/api/src',
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
                localRoot = vim.fn.getcwd() .. '/api/src',
                remoteRoot = '/apps/bi-portal',
            },
        },
        justMyCode = false,
    },
}
