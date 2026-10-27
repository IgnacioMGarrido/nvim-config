vim.opt.rtp:prepend(vim.fn.getcwd())
require('config.cpp')

vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    '    [[nodiscard]] virtual std::pair<int, int> value(',
    '        int index) const = 0;',
})
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.cmd('ToMock')
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), {
    '    MOCK_METHOD(',
    '        (std::pair<int, int>),',
    '        value,',
    '        (int index),',
    '        (const, override));',
}))

vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    'TEST_CASE_METHOD(Fixture,',
    '    "TC09 - first test", "[tag]") {}',
    'TEST_CASE_METHOD(Fixture,',
    '    "22 - second test", "[tag]") {}',
})
vim.cmd('NumberTests')
local numbered = vim.api.nvim_buf_get_lines(0, 0, -1, false)
assert(numbered[2] == '    "TC01 - first test", "[tag]") {}')
assert(numbered[4] == '    "TC02 - second test", "[tag]") {}')
vim.cmd('NumberTests')
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), numbered))

print('Extracted C++ command tests passed')
