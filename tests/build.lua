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

print('Streamed build output tests passed')
