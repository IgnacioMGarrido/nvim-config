local utils = {}

-- Search backward from the cursor for a Catch2 test name.
-- Handles TEST_CASE, TEST_CASE_METHOD, and SCENARIO, including multi-line declarations.
utils.catch2_test_name_at_cursor = function()
    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local total_lines = vim.api.nvim_buf_line_count(0)

    for i = cur_line, math.max(1, cur_line - 30), -1 do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] or ''

        if line:match('TEST_CASE_METHOD%s*%(') or line:match('TEST_CASE%s*%(') or line:match('SCENARIO%s*%(') then
            -- Concatenate following lines to handle multi-line macro declarations
            local block = line
            for j = i + 1, math.min(total_lines, i + 5) do
                block = block .. ' ' .. (vim.api.nvim_buf_get_lines(0, j - 1, j, false)[1] or '')
                if block:find('"[^"]*"') then break end
            end

            local name = block:match('TEST_CASE_METHOD%s*%([^,]+,%s*"([^"]+)"')
                      or block:match('TEST_CASE%s*%(%s*"([^"]+)"')
                      or block:match('SCENARIO%s*%(%s*"([^"]+)"')
            if name then return name end
        end
    end
    return nil
end

return utils
