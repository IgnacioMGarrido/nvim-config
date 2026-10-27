vim.opt.rtp:prepend(vim.fn.getcwd())
package.loaded['config.lazy'] = nil
package.preload['config.lazy'] = function()
    assert(vim.g.have_nerd_font == true, 'font settings must precede plugin setup')
    assert(vim.g.mapleader == ' ' and vim.g.maplocalleader == ' ')
    dofile('lua/plugins/obsidian.lua').init()
    return {}
end

dofile('init.lua')
assert(vim.fn.maparg(' o', 'n') == '', 'Obsidian prefix must not run a standalone action')
assert(vim.fn.maparg(' rs', 'n') ~= '', 'source action must have a non-prefix binding')
assert(vim.go.conceallevel == 0)
local source = vim.api.nvim_get_current_buf()
vim.bo.filetype = 'cpp'
vim.cmd('new')
local markdown = vim.api.nvim_get_current_buf()
vim.bo.filetype = 'markdown'
assert(vim.wo.conceallevel == 2)
assert(vim.go.conceallevel == 0, 'Markdown concealment must not change the default')

vim.api.nvim_win_set_buf(0, source)
assert(vim.wo.conceallevel == 0, 'source buffers must keep their concealment setting')
vim.api.nvim_win_set_buf(0, markdown)
assert(vim.wo.conceallevel == 2)

print('Startup ordering and Markdown concealment tests passed')
