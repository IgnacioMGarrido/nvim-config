local noop = function() end
local breakpoints = {}
package.loaded['dap'] = setmetatable({
    adapters = {},
    listeners = {
        before = { attach = {}, launch = {} },
        after = { event_terminated = {}, event_exited = {} },
    },
}, { __index = function() return noop end })
package.loaded['dapui'] = setmetatable({}, { __index = function() return noop end })
package.loaded['nvim-dap-virtual-text'] = { setup = noop }
package.loaded['dap.breakpoints'] = { get = function() return breakpoints end }

dofile('lua/plugins/dap.lua')[1].config()

local first = vim.api.nvim_create_buf(true, false)
local second = vim.api.nvim_create_buf(true, false)
for _, buf in ipairs({ first, second }) do
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn['repeat']({ '' }, 120))
end
breakpoints[first] = { { line = 100 }, { line = 5 } }
breakpoints[second] = { { line = 20 }, { line = 1 } }

local function jump(key, buf, line)
    vim.fn.maparg(key, 'n', false, true).callback()
    assert(vim.api.nvim_get_current_buf() == buf)
    assert(vim.api.nvim_win_get_cursor(0)[1] == line)
end

vim.api.nvim_set_current_buf(first)
vim.api.nvim_win_set_cursor(0, { 5, 0 })
jump(']b', first, 100)
jump(']b', second, 1)
jump(']b', second, 20)
jump(']b', first, 5)
jump('[b', second, 20)
jump('[b', second, 1)
jump('[b', first, 100)

vim.api.nvim_win_set_cursor(0, { 50, 0 })
jump('[b', first, 5)
vim.api.nvim_win_set_cursor(0, { 50, 0 })
jump(']b', first, 100)

breakpoints = {}
jump(']b', first, 100)

for _, background in ipairs({ 'light', 'dark' }) do
    vim.o.background = background
    vim.cmd.colorscheme('default')
    local stopped = vim.api.nvim_get_hl(0, { name = 'DapStoppedLine', link = false })
    local cursorline = vim.api.nvim_get_hl(0, { name = 'CursorLine', link = false })
    assert(vim.deep_equal(stopped, cursorline), 'stopped lines must follow the active theme')
    local breakpoint = vim.api.nvim_get_hl(0, { name = 'DapBreakpoint', link = false })
    local diagnostic = vim.api.nvim_get_hl(0, { name = 'DiagnosticError', link = false })
    assert(breakpoint.fg == diagnostic.fg, 'breakpoint colors must survive colorscheme reloads')
end

print('Breakpoint navigation and theme-aware debugger tests passed')
