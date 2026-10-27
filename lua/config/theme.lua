local theme = {}

theme.opts = {
    theme = "lotus",
    transparent = false,
}

function theme.apply()
    vim.o.background = "light"
    require("kanagawa").setup(theme.opts)
    vim.cmd.colorscheme("kanagawa-lotus")
end

function theme.toggle_transparent()
    theme.opts.transparent = not theme.opts.transparent
    theme.apply()
end

return theme
