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

for _, case in ipairs({
    { declaration = { 'TEST_CASE("long test", "[tag]") {' }, name = 'long test' },
    {
        declaration = { 'TEST_CASE_METHOD(', '    Fixture,', '    "method test",', '    "[tag]") {' },
        name = 'method test',
    },
    { declaration = { 'SCENARIO("long scenario", "[tag]") {' }, name = 'long scenario' },
}) do
    local lines = { 'TEST_CASE("earlier test", "[tag]") {}', '' }
    vim.list_extend(lines, case.declaration)
    vim.list_extend(lines, vim.fn['repeat']({ '    CHECK(true);' }, 80))
    lines[#lines + 1] = '    // TEST_CASE("not a real test")'
    lines[#lines + 1] = '}'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, { #lines - 1, 0 })
    assert(require('utils').catch2_test_name_at_cursor() == case.name)
end

vim.api.nvim_buf_set_lines(0, 0, -1, false, { '// TEST_CASE("comment only")', 'int helper();' })
vim.api.nvim_win_set_cursor(0, { 2, 0 })
assert(require('utils').catch2_test_name_at_cursor() == nil)

print('C++ commands and long Catch2 test detection passed')
