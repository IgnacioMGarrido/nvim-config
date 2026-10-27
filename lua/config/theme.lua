local theme = {}

theme.opts = {
    theme = "lotus",
    transparent = false,
    commentStyle = { italic = false },
    keywordStyle = { italic = false },
    colors = {
        palette = {
            lotusWhite3 = "#e5ddb0",
        },
        theme = {
            lotus = {
                syn = {
                    comment = "#616059",
                    deprecated = "#616059",
                    constant = "#934d00",
                    fun = "#395581",
                    identifier = "#5c562f",
                    number = "#8d405a",
                    operator = "#665538",
                    preproc = "#a32f40",
                    punct = "#35677b",
                    regex = "#665538",
                    special1 = "#3d6287",
                    special2 = "#a32f40",
                    special3 = "#a32f40",
                    string = "#4e6636",
                    type = "#3f615b",
                },
            },
        },
    },
}

function theme.apply()
    vim.o.background = "light"
    require("kanagawa").setup(theme.opts)
    vim.cmd.colorscheme("kanagawa-lotus")
    vim.opt.guicursor:append("a:Cursor/lCursor")
end

function theme.toggle_transparent()
    theme.opts.transparent = not theme.opts.transparent
    theme.apply()
end

return theme
