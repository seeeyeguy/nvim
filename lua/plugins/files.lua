local customutils = require("custom.utils")

return {
    'echasnovski/mini.files',
    version = false,
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local minifiles = require('mini.files')
        minifiles.setup({
            mappings = {
                close      = 'q',
                go_in      = 'l',
                go_in_plus = '<CR>',
                go_out     = 'h',
                go_out_plus = 'H',
                mark_goto  = "'",
                mark_set   = 'm',
                reset      = '<BS>',
                reveal_cwd = '@',
                show_help  = 'g?',
                synchronize = '=',
                trim_left  = '>',
                trim_right = '<',
            },
            options = { permanent_delete = true, use_as_default_explorer = true },
            windows = { max_number = math.huge, preview = false, width_focus = 50, width_nofocus = 15, width_preview = 25 },
        })

        -- Open in split or tab from within explorer
        local function map_open(buf_id, lhs, action, direction)
            local rhs = function()
                if action == "split" then
                    local cur_target = minifiles.get_explorer_state().target_window
                    local new_target = vim.api.nvim_win_call(cur_target, function()
                        vim.cmd(direction .. ' split')
                        return vim.api.nvim_get_current_win()
                    end)
                    minifiles.set_target_window(new_target)
                    minifiles.go_in()
                elseif action == "tab" then
                    local file_path = minifiles.get_fs_entry().path
                    minifiles.close()
                    vim.cmd('tabnew ' .. vim.fn.fnameescape(file_path))
                    minifiles.open(vim.api.nvim_buf_get_name(0), true)
                end
            end
            vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = action == "split" and ('Split ' .. direction) or 'Open in tab' })
        end

        local function set_cwd()
            local path = (MiniFiles.get_fs_entry() or {}).path
            if path then vim.fn.chdir(vim.fs.dirname(path)) else vim.notify('Cursor not on valid entry') end
        end

        local function yank_path()
            local path = (MiniFiles.get_fs_entry() or {}).path
            if path then vim.fn.setreg(vim.v.register, path) else vim.notify('Cursor not on valid entry') end
        end

        vim.api.nvim_create_autocmd('User', {
            pattern  = 'MiniFilesBufferCreate',
            callback = function(args)
                local buf_id = args.data.buf_id
                map_open(buf_id, '<Leader>s', 'split', 'belowright horizontal')
                map_open(buf_id, '<Leader>v', 'split', 'belowright vertical')
                map_open(buf_id, '<Leader>t', 'tab')
                vim.keymap.set('n', '<C-p>', function() MiniFiles.config.windows.preview = not MiniFiles.config.windows.preview end,
                    { buffer = buf_id, desc = 'Toggle file preview' })
                vim.keymap.set('n', 'g@',   set_cwd,   { buffer = buf_id, desc = 'Set cwd' })
                vim.keymap.set('n', 'gy',   yank_path, { buffer = buf_id, desc = 'Yank path' })
                vim.keymap.set('n', '<Esc>', function() minifiles.close() end, { buffer = buf_id, desc = 'Close' })
                vim.keymap.set('n', '<C-h>', 'h', { buffer = buf_id, desc = 'Navigate left' })
                vim.keymap.set('n', '<C-l>', 'l', { buffer = buf_id, desc = 'Navigate right' })
            end,
        })

        local map = vim.keymap
        map.set('n', '<Leader>e', function()
            local path = vim.api.nvim_buf_get_name(0)
            minifiles.open(path ~= '' and vim.uv.fs_stat(path) and path or nil, true)
        end, { noremap = true, silent = true, desc = "Files: Open explorer (file or cwd)" })
        map.set('n', '<Leader>E', function() minifiles.open() end,
            { noremap = true, silent = true, desc = "Files: Open explorer (cwd)" })

        -- Bookmarks
        local function set_mark(id, path, desc)
            if vim.fn.isdirectory(vim.fn.expand(path)) ~= 0 then
                MiniFiles.set_bookmark(id, path, { desc = desc })
            else
                vim.notify(
                    "MiniFiles: Invalid bookmark path **" .. path .. "**\n\nUpdate: " ..
                    vim.fn.stdpath('config') .. "/lua/local/minifiles/bookmarks.lua",
                    vim.log.levels.INFO, { timeout = 5000 })
            end
        end

        vim.api.nvim_create_autocmd('User', {
            pattern  = 'MiniFilesExplorerOpen',
            callback = function()
                set_mark('c', vim.fn.stdpath('config'), 'Config')
                set_mark('n', vim.fn.stdpath('data'),   'Nvim-Data')
                set_mark('w', vim.fn.getcwd(),          'Working directory')
                set_mark('h', '~',                      'Home directory')
                set_mark('~', '~',                      'Home directory')
                local bookmarks = customutils.safe_require('local.minifiles.bookmarks', {})
                for _, bookmark in ipairs(bookmarks) do
                    set_mark(bookmark.id, bookmark.path, bookmark.desc)
                end
            end,
        })
    end,
}
