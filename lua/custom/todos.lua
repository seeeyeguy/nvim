local fn  = vim.fn
local cmd = vim.cmd

local function markdown_update_todos()
    local date_today = os.date("%Y-%m-%d")
    local home_dir   = os.getenv("HOME") or os.getenv("USERPROFILE")
    local todos_file = home_dir .. "/todos.md"

    if fn.filereadable(todos_file) == 0 then fn.writefile({}, todos_file) end

    local lines = fn.readfile(todos_file)
    local today_exists = false
    local unchecked_items = {}
    local indent_level, start_collecting = nil, nil
    local max_date, current_date = nil, nil
    local inside_previous_date = false
    local lines_to_remove = {}
    local inside_sub_header, current_sub_header = false, nil
    local header_added = false
    local final_lines = {}

    for i, line in ipairs(lines) do
        if line:match('^# %d%d%d%d%-%d%d%-%d%d') then
            current_date = line:match('%d%d%d%d%-%d%d%-%d%d')
            if max_date == nil or current_date > max_date then max_date = current_date end
        elseif line == '' then
            table.insert(lines_to_remove, i)
        end
    end

    if max_date == date_today then today_exists = true end

    if not today_exists then
        for i = #lines_to_remove, 1, -1 do table.remove(lines, lines_to_remove[i]) end
        lines_to_remove = {}

        for i, line in ipairs(lines) do
            if line:match('^# %d%d%d%d%-%d%d%-%d%d') and line:match('%d%d%d%d%-%d%d%-%d%d') == max_date then
                inside_previous_date = true
            end
            if inside_previous_date then
                if line:match('^## *') then
                    if line ~= lines[current_sub_header] then
                        inside_sub_header = true; current_sub_header = i; header_added = false
                    end
                end
                if line:match('%- %[[ xX]%]') or line:match('%- ') then
                    indent_level = #line:match('^%s*')
                    if indent_level == 0 then
                        if line:match('%- %[ %]') then
                            start_collecting = true
                            if inside_sub_header and not header_added then
                                table.insert(unchecked_items, lines[current_sub_header])
                                header_added = true
                            end
                            table.insert(unchecked_items, line)
                            table.insert(lines_to_remove, i)
                        else
                            start_collecting = false
                        end
                    elseif start_collecting then
                        table.insert(unchecked_items, line)
                        table.insert(lines_to_remove, i)
                    end
                end
            end
        end

        for i = #lines_to_remove, 1, -1 do table.remove(lines, lines_to_remove[i]) end
        table.insert(lines, "# " .. date_today)
        for _, item in ipairs(unchecked_items) do table.insert(lines, item) end

        for i, line in ipairs(lines) do
            if line:match('^#') and (i + 1 <= #lines and lines[i + 1]:match('^#') and not line:match('^# %d%d%d%d%-%d%d%-%d%d')) then
                -- skip empty line between headers
            elseif line:match('^#') or (i + 1 <= #lines and lines[i + 1]:match('^#')) then
                table.insert(final_lines, line); table.insert(final_lines, '')
            elseif not line:match('^|') and i + 1 <= #lines and lines[i + 1]:match('^|') then
                table.insert(final_lines, line); table.insert(final_lines, '')
            else
                table.insert(final_lines, line)
            end
        end

        fn.writefile(final_lines, todos_file)
    end

    cmd("edit " .. todos_file)
end

vim.api.nvim_create_user_command("MarkdownUpdateTodos", markdown_update_todos,
    { desc = "Markdown: Open todos.md and run date automation" })

vim.api.nvim_set_keymap("n", "<M-m><M-t>", ":MarkdownUpdateTodos<CR>",
    { noremap = true, silent = true, desc = "Markdown: Open todos" })
