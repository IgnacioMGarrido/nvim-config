-- Quick fix after make
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = { "make", "grep" },
    callback = function()
        vim.cmd("vert copen")
    end,
})

local _vmake_source_win = nil

-- In the quickfix window, open errors in the source window that triggered the build
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    callback = function()
        vim.keymap.set('n', '<CR>', function()
            local item = vim.fn.getqflist()[vim.fn.line('.')]
            if not item then return end

            local target = (_vmake_source_win and vim.api.nvim_win_is_valid(_vmake_source_win))
                and _vmake_source_win
                or nil

            if not target then
                vim.cmd('vsplit')
                target = vim.api.nvim_get_current_win()
            end

            vim.api.nvim_set_current_win(target)
            if item.bufnr ~= 0 and vim.api.nvim_buf_is_loaded(item.bufnr) then
                vim.api.nvim_win_set_buf(target, item.bufnr)
            else
                vim.cmd('edit ' .. vim.fn.fnameescape(item.filename ~= '' and item.filename or vim.fn.bufname(item.bufnr)))
            end
            vim.api.nvim_win_set_cursor(target, { item.lnum, math.max(0, item.col - 1) })
        end, { buffer = true })
    end,
})

vim.api.nvim_create_user_command("Vmake", function(opts)
    local cmd = vim.o.makeprg .. (opts.args ~= "" and " " .. opts.args or "")
    local errorformat = vim.o.errorformat
    _vmake_source_win = vim.api.nvim_get_current_win()
    vim.cmd("vnew")
    vim.cmd("setlocal buftype=nofile bufhidden=hide noswapfile")

    if not opts.bang then
        vim.fn.termopen(cmd)
        return
    end

    -- Close any existing quickfix window before starting a new build
    vim.cmd('cclose')

    -- Bang variant: capture output into buffer + populate quickfix on exit
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local output = {}
    local partial = { stdout = "", stderr = "" }

    local function append(lines)
        if #lines == 0 then return end
        vim.list_extend(output, lines)
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
            if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
                vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
            end
        end
    end

    local function collect(stream, data)
        if not data or #data == 0 then return end
        local lines = vim.list_slice(data)
        lines[1] = partial[stream] .. lines[1]
        partial[stream] = table.remove(lines)
        append(lines)
    end

    vim.fn.jobstart(cmd, {
        on_stdout = function(_, data) collect("stdout", data) end,
        on_stderr = function(_, data) collect("stderr", data) end,
        on_exit = function(_, code)
            for _, stream in ipairs({ "stdout", "stderr" }) do
                if partial[stream] ~= "" then append({ partial[stream] }) end
            end
            vim.fn.setqflist({}, ' ', { lines = output, efm = errorformat })
            if code ~= 0 then
                pcall(vim.api.nvim_win_close, win, true)
                vim.cmd('vert copen')
                vim.cmd('vertical resize ' .. math.floor(vim.o.columns / 2))
            end
        end,
    })
end, { nargs = "*", bang = true })

vim.keymap.set("n", "<leader>l", ":Vmake!<CR>", { desc = "Make project" })
