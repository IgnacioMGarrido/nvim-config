vim.opt.rtp:prepend(vim.fn.getcwd())
package.loaded['config.lazy'] = {}
dofile('init.lua')

local jobstart = vim.fn.jobstart
local callbacks
vim.fn.jobstart = function(_, opts)
    callbacks = opts
    return 1
end

vim.o.makeprg = 'unused'
vim.o.errorformat = '%f:%l:%c: %m'
local build_source = vim.api.nvim_get_current_win()
vim.cmd('Vmake!')
local log = vim.api.nvim_get_current_buf()
vim.o.errorformat = '%m'
callbacks.on_stdout(nil, { 'split.cpp:12:' })
callbacks.on_stderr(nil, { 'stderr.cpp:8:' })
callbacks.on_stdout(nil, { '4: error: stdout', '' })
callbacks.on_stderr(nil, { '2: error: stderr', '' })
callbacks.on_stdout(nil, { '', 'final.cpp:20:3: warning: no newline' })
callbacks.on_stdout(nil, { '' })
callbacks.on_exit(nil, 0)
assert(vim.fn.getqflist({ context = 0 }).context.vmake_source_win == build_source)

local valid = vim.tbl_filter(function(item) return item.valid == 1 end, vim.fn.getqflist())
assert(#valid == 3, vim.inspect(vim.fn.getqflist()))
assert(valid[1].lnum == 12 and valid[1].col == 4 and valid[1].text == 'error: stdout')
assert(valid[2].lnum == 8 and valid[2].col == 2 and valid[2].text == 'error: stderr')
assert(valid[3].lnum == 20 and valid[3].text == 'warning: no newline')
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(log, 0, -1, false), {
    '',
    'split.cpp:12:4: error: stdout',
    'stderr.cpp:8:2: error: stderr',
    '',
    'final.cpp:20:3: warning: no newline',
}))

vim.o.errorformat = '%f:%l:%c: %m'
vim.cmd('Vmake!')
vim.api.nvim_buf_delete(vim.api.nvim_get_current_buf(), { force = true })
callbacks.on_stdout(nil, { 'closed.cpp:1:1: error: closed log', '' })
callbacks.on_exit(nil, 0)
assert(vim.fn.getqflist()[1].valid == 1)

vim.fn.jobstart = jobstart
vim.fn.setqflist({})
vim.o.makeprg = "printf 'actual.cpp:3:'; sleep 0.05; printf '2: error: actual\\n'; exit 1"
vim.cmd('Vmake!')
assert(vim.wait(3000, function() return #vim.fn.getqflist() > 0 end), 'build did not finish')
local actual = vim.fn.getqflist()
assert(#actual == 1 and actual[1].valid == 1 and actual[1].lnum == 3 and actual[1].col == 2)

local function enter_result()
    vim.fn.maparg('<CR>', 'n', false, true).callback()
end

vim.cmd('cclose')
vim.fn.setqflist({}, ' ', { items = { { text = 'Building CXX object', valid = 0 } } })
vim.cmd('copen')
local qf_win = vim.api.nvim_get_current_win()
local notice
local notify = vim.notify
vim.notify = function(message, level) notice = { message, level } end
enter_result()
vim.notify = notify
assert(vim.api.nvim_get_current_win() == qf_win)
assert(notice and notice[2] == vim.log.levels.WARN, 'log rows need an explicit warning')
vim.cmd('cclose')

local source = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(source, 0, -1, false, vim.fn['repeat']({ 'source code' }, 20))
vim.cmd('vnew')
local source_win = vim.api.nvim_get_current_win()
vim.api.nvim_win_set_buf(source_win, source)
vim.cmd('vsplit')
vim.fn.setqflist({}, ' ', {
    items = { { bufnr = source, lnum = 10, col = 2, text = 'build error' } },
    context = { vmake_source_win = source_win },
})
vim.cmd('copen')
enter_result()
assert(vim.api.nvim_get_current_win() == source_win, 'build errors must use their source window')
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 10, 1 }))
vim.cmd('cclose')

local location_source = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(location_source, 0, -1, false, vim.fn['repeat']({ 'location code' }, 10))
vim.fn.setloclist(0, {}, ' ', {
    items = { { bufnr = location_source, lnum = 5, col = 3, text = 'location error' } },
})
vim.cmd('lopen')
enter_result()
assert(vim.api.nvim_get_current_win() == source_win)
assert(vim.api.nvim_get_current_buf() == location_source, 'location lists must not use quickfix items')
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { 5, 2 }))
vim.cmd('lclose')

vim.cmd('vnew')
local closed_win = vim.api.nvim_get_current_win()
vim.api.nvim_win_close(closed_win, true)
vim.fn.setqflist({}, ' ', {
    items = { { bufnr = source, lnum = 3, col = 1, text = 'another error' } },
    context = { vmake_source_win = closed_win },
})
vim.cmd('copen')
enter_result()
assert(vim.api.nvim_get_current_buf() == source, 'closed source windows need native quickfix routing')
assert(vim.api.nvim_win_get_cursor(0)[1] == 3)

print('Build output and quickfix navigation tests passed')
