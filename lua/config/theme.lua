local theme = {}

theme.opts = {
    darkness = "warm",
    transparent_background = false,
    italic_comments = false,
    italic_strings = false,
}

function theme.apply()
    vim.g.zenbones = theme.opts
    vim.o.background = "dark"
    vim.cmd.colorscheme("zenbones")
    vim.opt.guicursor:append("a:Cursor/lCursor")
end

function theme.toggle_transparent()
    theme.opts.transparent_background = not theme.opts.transparent_background
    theme.apply()
end

return theme
