local theme = {}

theme.opts = {
    theme = "wave",
    transparent = false,
}

function theme.apply()
    require("kanagawa").setup(theme.opts)
    vim.cmd.colorscheme("kanagawa-wave")
end

function theme.toggle_transparent()
    theme.opts.transparent = not theme.opts.transparent
    theme.apply()
end

return theme
