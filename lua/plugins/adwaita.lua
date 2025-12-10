return {
    "travisvroman/adwaita.nvim",
    lazy = false,
    priority = 1000,

    -- configure and set on startup
    config = function()
        -- vim.g.adwaita_darker = true -- for darker version
        -- vim.g.adwaita_disable_cursorline = true -- to disable cursorline
        -- vim.g.adwaita_transparent = true        -- makes the background transparent

        vim.opt.termguicolors = true
        vim.cmd('colorscheme adwaita')
        vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
        vim.cmd("hi LineNr guibg=NONE ctermbg=NONE")
        vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
        vim.cmd("hi WinBar guibg=NONE ctermbg=NONE")
    end
}
