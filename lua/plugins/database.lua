return {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
        { 'tpope/vim-dadbod',                 lazy = true },
        { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    init = function()
        vim.g.db_ui_use_nerd_fonts      = 1
        vim.g.db_ui_use_nvim_notify     = 1
        vim.g.db_ui_show_database_icon  = 1
        vim.g.db_ui_disable_progress_bar = 1
        vim.g.db_ui_save_location = vim.fn.stdpath('config') .. '/lua/local/vim_dadbod_ui'
        vim.keymap.set('n', '<A-s><A-u>', ':DBUIToggle<CR>', { silent = true, desc = 'DB: Toggle DBUI' })
    end,
    config = function()
        local function execute_sql_under_cursor()
            local ts_utils = require('nvim-treesitter.ts_utils')
            local node = ts_utils.get_node_at_cursor()
            while node and node:type() ~= 'statement' do node = node:parent() end
            if node then
                local start_row, _, end_row, _ = node:range()
                vim.cmd((start_row + 1) .. ',' .. (end_row + 1) .. 'DB')
            else
                print('No SQL statement found under cursor.')
            end
        end

        local result_bufnr = nil
        local function toggle_result_buffer()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == "dbout" then
                    result_bufnr = buf
                    vim.api.nvim_win_close(win, true)
                    return
                end
            end
            if result_bufnr and vim.api.nvim_buf_is_valid(result_bufnr) then
                vim.cmd("split | wincmd J")
                vim.api.nvim_set_current_buf(result_bufnr)
            else
                print("No previous result buffer found.")
            end
        end

        vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'sql', 'mysql', 'plsql' },
            callback = function()
                vim.keymap.set('n', '<C-CR>', execute_sql_under_cursor, { silent = true, buffer = true, desc = 'DB: Execute SQL under cursor' })
                vim.keymap.set('v', '<C-CR>', ':DB<CR>',                 { silent = true, buffer = true, desc = 'DB: Execute selected SQL' })
                vim.keymap.set('n', '<A-s><A-r>', toggle_result_buffer,  { silent = true, desc = 'DB: Toggle result buffer' })
            end,
        })
    end,
}
