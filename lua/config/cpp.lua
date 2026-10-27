-- Convert a C++ pure virtual method declaration under the cursor into a
-- GMock MOCK_METHOD macro. Works with multi-line declarations, template
-- return types, const qualifiers, and [[nodiscard]] attributes.
local function virtual_to_mock()
    local buf = 0
    local cursor = vim.api.nvim_win_get_cursor(0)
    local start_line = cursor[1] - 1 -- 0-indexed

    -- Collect lines until we hit a semicolon
    local raw_lines = {}
    local end_line = start_line
    local total_lines = vim.api.nvim_buf_line_count(buf)
    while end_line < total_lines do
        local line = vim.api.nvim_buf_get_lines(buf, end_line, end_line + 1, false)[1]
        table.insert(raw_lines, line)
        if line:find(";") then break end
        end_line = end_line + 1
    end

    local indent = raw_lines[1]:match("^(%s*)")

    -- Join lines and collapse whitespace
    local text = table.concat(raw_lines, " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

    -- Strip [[...]] attributes and virtual keyword
    text = text:gsub("%[%[.-%]%]%s*", "")
    text = text:gsub("^virtual%s+", "")

    -- Detect trailing const qualifier (only the one after the params, not inside them)
    local is_const = text:match("%)%s*const%s*[=;]") ~= nil

    -- Strip trailing qualifiers and semicolon
    text = text:gsub("%s*const%s*=%s*0%s*;.*$", "")
    text = text:gsub("%s*=%s*0%s*;.*$", "")
    text = text:gsub("%s*;.*$", "")
    text = text:gsub("%s*$", "")

    -- Find the last ')' — end of the parameter list
    local close_pos = #text
    while close_pos > 0 and text:sub(close_pos, close_pos) ~= ")" do
        close_pos = close_pos - 1
    end
    if close_pos == 0 then
        vim.notify("[ToMock] Could not find closing paren", vim.log.levels.ERROR)
        return
    end

    -- Walk back to find the matching '(' (skip nested parens)
    local depth = 0
    local open_pos = close_pos
    while open_pos > 0 do
        local c = text:sub(open_pos, open_pos)
        if c == ")" then
            depth = depth + 1
        elseif c == "(" then
            depth = depth - 1
            if depth == 0 then break end
        end
        open_pos = open_pos - 1
    end
    if open_pos == 0 then
        vim.notify("[ToMock] Could not find opening paren", vim.log.levels.ERROR)
        return
    end

    local params = text:sub(open_pos + 1, close_pos - 1):gsub("^%s+", ""):gsub("%s+$", "")
    local before  = text:sub(1, open_pos - 1):gsub("%s+$", "")

    -- Method name is the last identifier before '('
    local method_name = before:match("([%w_~]+)%s*$")
    if not method_name then
        vim.notify("[ToMock] Could not extract method name", vim.log.levels.ERROR)
        return
    end
    local return_type = before:sub(1, #before - #method_name):gsub("%s+$", "")

    -- MOCK_METHOD requires parens around the return type when it contains commas
    local ret_str    = return_type:find(",") and ("(" .. return_type .. ")") or return_type
    local params_str = "(" .. params .. ")"
    local spec_str   = is_const and "(const, override)" or "(override)"

    local inner = indent .. "    "
    local result = {
        indent .. "MOCK_METHOD(",
        inner  .. ret_str    .. ",",
        inner  .. method_name .. ",",
        inner  .. params_str .. ",",
        inner  .. spec_str   .. ");",
    }

    vim.api.nvim_buf_set_lines(buf, start_line, end_line + 1, false, result)
end

vim.api.nvim_create_user_command("ToMock", function() virtual_to_mock() end, {})
vim.keymap.set("n", "<leader>tm", function() virtual_to_mock() end, { desc = "Convert virtual method to MOCK_METHOD" })

local function number_tests(opts)
  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local lookahead = 5
  local n = 0
  local i = 1

  while i <= #lines do
    if lines[i]:match("^%s*TEST_CASE_METHOD%(") then
      local j = i + 1
      local maxj = math.min(#lines, i + lookahead)
      while j <= maxj do
        if lines[j]:match('^%s*".*') then
          local line = lines[j]
          line = line:gsub('^(%s*")TC%d+%s+%-%s+', '%1', 1)
          line = line:gsub('^(%s*")%d+%s+%-%s+', '%1', 1)
          n = n + 1
          local prefix = string.format("TC%02d - ", n)
          line = line:gsub('^(%s*")', '%1' .. prefix, 1)
          lines[j] = line
          i = j
          break
        end
        j = j + 1
      end
    end
    i = i + 1
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

vim.api.nvim_create_user_command("NumberTests", function() number_tests() end, {})
vim.keymap.set("n", "<leader>tn", function() number_tests() end, { desc = "Number TEST_CASE_METHOD" })
