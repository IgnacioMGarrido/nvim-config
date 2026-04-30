return {
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
            'theHamsta/nvim-dap-virtual-text',
            {
                'jay-babu/mason-nvim-dap.nvim',
                dependencies = { 'mason-org/mason.nvim' },
                opts = {
                    ensure_installed = { 'codelldb' },
                    handlers = {},
                },
            },
        },
        config = function()
            local dap = require('dap')
            local dapui = require('dapui')

            dap.adapters.codelldb = {
                type = 'server',
                port = '${port}',
                executable = {
                    command = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/codelldb',
                    args = { '--port', '${port}' },
                },
            }

            -- Auto open/close UI on session start/end
            dap.listeners.before.attach.dapui_config = function() dapui.open() end
            dap.listeners.before.launch.dapui_config = function() dapui.open() end
            dap.listeners.after.event_terminated.dapui_config = function() dapui.close() end
            dap.listeners.after.event_exited.dapui_config = function() dapui.close() end

            vim.fn.sign_define('DapBreakpoint',         { text = '●', texthl = 'DapBreakpoint',         linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointRejected',  { text = '●', texthl = 'DapBreakpointRejected',  linehl = '', numhl = '' })
            vim.fn.sign_define('DapLogPoint',            { text = '◎', texthl = 'DapLogPoint',            linehl = '', numhl = '' })
            vim.fn.sign_define('DapStopped',             { text = '▶', texthl = 'DapStopped',             linehl = 'DapStoppedLine', numhl = '' })

            vim.api.nvim_set_hl(0, 'DapBreakpoint',         { fg = '#e06c75' })
            vim.api.nvim_set_hl(0, 'DapBreakpointCondition',{ fg = '#e5c07b' })
            vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#555555' })
            vim.api.nvim_set_hl(0, 'DapLogPoint',           { fg = '#61afef' })
            vim.api.nvim_set_hl(0, 'DapStopped',            { fg = '#98c379' })
            vim.api.nvim_set_hl(0, 'DapStoppedLine',        { bg = '#2a3d2a' })

            require('nvim-dap-virtual-text').setup()
            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = 'scopes',      size = 0.40 },
                            { id = 'breakpoints', size = 0.20 },
                            { id = 'stacks',      size = 0.20 },
                            { id = 'watches',     size = 0.20 },
                        },
                        size = 40,
                        position = 'left',
                    },
                    {
                        elements = {
                            { id = 'console', size = 0.70 },
                            { id = 'repl',    size = 0.30 },
                        },
                        size = 15,
                        position = 'bottom',
                    },
                },
            })

            vim.keymap.set('n', '<leader>dc', dap.continue, { desc = '[d]ebug [c]ontinue / start' })
            vim.keymap.set('n', '<leader>dn', dap.step_over, { desc = '[d]ebug step [n]ext' })
            vim.keymap.set('n', '<leader>di', dap.step_into, { desc = '[d]ebug step [i]nto' })
            vim.keymap.set('n', '<leader>do', dap.step_out, { desc = '[d]ebug step [o]ut' })
            vim.keymap.set('n', '<leader>dr', dap.run_to_cursor, { desc = '[d]ebug [r]un to cursor' })
            vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = '[d]ebug run [l]ast' })
            vim.keymap.set('n', '<leader>dx', dap.terminate, { desc = '[d]ebug terminate' })
            vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = '[d]ebug toggle [u]i' })
            vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[d]ebug toggle [b]reakpoint' })

            local function goto_breakpoint(direction)
                local all = {}
                for bufnr, buf_bps in pairs(require('dap.breakpoints').get()) do
                    for _, bp in ipairs(buf_bps) do
                        table.insert(all, { bufnr = bufnr, line = bp.line })
                    end
                end
                if #all == 0 then return end
                table.sort(all, function(a, b)
                    return a.bufnr ~= b.bufnr and a.bufnr < b.bufnr or a.line < b.line
                end)

                local cur_buf = vim.api.nvim_get_current_buf()
                local cur_line = vim.api.nvim_win_get_cursor(0)[1]
                local idx

                for i, bp in ipairs(all) do
                    if bp.bufnr == cur_buf and bp.line == cur_line then idx = i; break end
                end

                local next_idx
                if idx then
                    next_idx = direction == 'next' and idx % #all + 1 or (idx - 2) % #all + 1
                elseif direction == 'next' then
                    next_idx = 1
                    for i, bp in ipairs(all) do
                        if bp.bufnr > cur_buf or (bp.bufnr == cur_buf and bp.line > cur_line) then
                            next_idx = i; break
                        end
                    end
                else
                    next_idx = #all
                    for i = #all, 1, -1 do
                        local bp = all[i]
                        if bp.bufnr < cur_buf or (bp.bufnr == cur_buf and bp.line < cur_line) then
                            next_idx = i; break
                        end
                    end
                end

                local target = all[next_idx]
                vim.api.nvim_win_set_buf(0, target.bufnr)
                vim.api.nvim_win_set_cursor(0, { target.line, 0 })
            end

            vim.keymap.set('n', ']b', function() goto_breakpoint('next') end, { desc = 'Next breakpoint' })
            vim.keymap.set('n', '[b', function() goto_breakpoint('prev') end, { desc = 'Prev breakpoint' })
            vim.keymap.set('n', '<leader>dB', function()
                dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end, { desc = '[d]ebug conditional [B]reakpoint' })
        end,
    },
}
