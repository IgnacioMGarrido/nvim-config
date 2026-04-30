require("config.lazy")
--
-- Basic Settings
--
vim.keymap.set("n", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.wrap = true
vim.o.scrolloff = 10
vim.o.sidescrolloff = 8
vim.o.clipboard = "unnamedplus"
vim.opt.switchbuf = { 'useopen', 'uselast' }

-- Indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.cindent = true

-- Search Settings
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true

-- Visual Settings
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "100"
vim.o.showmatch = true
vim.o.matchtime = 2
vim.o.cmdheight = 1
vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.showmode = false
vim.o.pumheight = 10
vim.o.pumblend = 10
vim.o.winblend = 0
vim.o.conceallevel = 0
vim.o.concealcursor = ""
vim.o.lazyredraw = true
vim.o.synmaxcol = 300

-- File Handling
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = vim.fn.expand("~/.vim/undodir")
vim.o.updatetime = 300
vim.o.timeoutlen = 500
vim.o.ttimeoutlen = 0
vim.o.autoread = true
vim.o.autowrite = false

-- Behavior Settings
vim.o.backspace = "indent,eol,start"
vim.o.autochdir = false
vim.o.encoding = "UTF-8"
vim.opt.errorbells = false
-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Performance improvements
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

vim.g.have_nerd_font = true

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set("n", "<leader>q", ":bd<CR>", { desc = "Close current buffer" })
-- Y to EOL
vim.keymap.set('n', "Y", "y$", { desc = "Yank to end of line." })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete without yanking" })

-- Quickfix navigation with wraparound
vim.keymap.set('n', ']q', function()
    if not pcall(vim.cmd, 'cnext') then vim.cmd('cfirst') end
end, { desc = 'Next quickfix (wraps)' })
vim.keymap.set('n', '[q', function()
    if not pcall(vim.cmd, 'cprev') then vim.cmd('clast') end
end, { desc = 'Prev quickfix (wraps)' })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Splitting & Resizing
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>h", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Move lines up/down
vim.keymap.set("n", "<A-J>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-K>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-J>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-K>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Quick file navigation
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find file" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Quick config editing
vim.keymap.set("n", "<leader>rc", function()
    vim.cmd("e " .. vim.fn.stdpath('config') .. "/init.lua")
end, { desc = "Edit config" })

-- Auto reload files if changed externally
vim.api.nvim_create_autocmd(
    { "FocusGained" },
    { command = "checktime" }
)

-- execute make per project
-- needs to create an .nvim.lua per project
vim.opt.exrc = true
vim.opt.secure = true
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

    local function append(data)
        if not data then return end
        if data[#data] == "" then table.remove(data) end
        if #data == 0 then return end
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
        vim.list_extend(output, data)
        pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(buf), 0 })
    end

    vim.fn.jobstart(cmd, {
        on_stdout = function(_, data) append(data) end,
        on_stderr = function(_, data) append(data) end,
        on_exit = function(_, code)
            vim.fn.setqflist({}, ' ', { lines = output, efm = vim.o.errorformat })
            if code ~= 0 then
                pcall(vim.api.nvim_win_close, win, true)
                vim.cmd('vert copen')
                vim.cmd('vertical resize ' .. math.floor(vim.o.columns / 2))
            end
        end,
    })
end, { nargs = "*", bang = true })

vim.keymap.set("n", "<leader>l", ":Vmake!<CR>", { desc = "Make project" })
-- ============================================================================
-- USEFUL FUNCTIONS
-- ============================================================================

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

vim.keymap.set("n", "<leader>bg", function()
    require("config.theme").toggle_transparent()
end, { desc = "Toggle transparent background" })

-- Copy Full File-Path
vim.keymap.set("n", "<leader>pa", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    print("file:", path)
end)

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Neovim 0.11 bug: treesitter highlighter crashes on terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function()
        pcall(vim.treesitter.stop)
    end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Return to last edit position when opening files

vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end,
})


-- ============================================================================

-- ============================================================================
-- STATUSLINE
-- ============================================================================
-- Git branch function
-- local function git_branch()
--   local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
--   if branch ~= "" then
--     return "  " .. branch .. " "
--   end
--   return ""
-- end
--
-- -- LSP status
-- local function lsp_status()
--   local clients = vim.lsp.get_clients({ bufnr = 0 })
--   if #clients > 0 then
--     return "  LSP "
--   end
--   return ""
-- end
--
-- -- Word count for text files
-- local function word_count()
--   local ft = vim.bo.filetype
--   if ft == "markdown" or ft == "text" or ft == "tex" then
--     local words = vim.fn.wordcount().words
--     return "  " .. words .. " words "
--   end
--   return ""
-- end
--
-- -- File size
-- local function file_size()
--   local size = vim.fn.getfsize(vim.fn.expand('%'))
--   if size < 0 then return "" end
--   if size < 1024 then
--     return size .. "B "
--   elseif size < 1024 * 1024 then
--     return string.format("%.1fK", size / 1024)
--   else
--     return string.format("%.1fM", size / 1024 / 1024)
--   end
-- end
-- ============================================================================
