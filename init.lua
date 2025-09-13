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

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set("n", "<leader>q", ":bd<CR>", { desc = "Close current buffe" })
-- Y to EOL
vim.keymap.set('n', "Y", "y$", { desc = "Yank to end of line." })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

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
vim.keymap.set("n", "<leader>rc", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })

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

vim.api.nvim_create_user_command("Vmake", function(opts)
    local cmd = vim.o.makeprg .. " " .. (opts.args or "")
    vim.cmd("vnew")
    vim.cmd("setlocal buftype=nofile bufhidden=hide noswapfile")
    vim.fn.termopen(cmd)
end, { nargs = "*" })


vim.keymap.set("n", "<leader>l", ":Vmake<CR>", { desc = "Make project" })
-- ============================================================================

-- Theme
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

-- ============================================================================
-- USEFUL FUNCTIONS
-- ============================================================================

vim.keymap.set("n", "<leader>bg", function()
    local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    local is_transparent = hl.bg == nil or hl.bg == "none"

    if is_transparent then
        vim.api.nvim_set_hl(0, "Normal", { bg = "#1e1e2e" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "#1e1e2e" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#1e1e2e" })
    else
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
    end
end)

-- Copy Full File-Path
vim.keymap.set("n", "<leader>pa", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    print("file:", path)
end)

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
