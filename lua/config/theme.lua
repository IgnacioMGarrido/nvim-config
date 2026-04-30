local theme = {}

theme.opts = {
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    transparent_background = false,
    integrations = {
        cmp = true,
        gitsigns = true,
        neo_tree = true,
        treesitter = true,
        telescope = { enabled = true },
        mini = { enabled = true },
        which_key = true,
        indent_blankline = { enabled = true },
        mason = true,
        native_lsp = {
            enabled = true,
            underlines = {
                errors = { "underline" },
                hints = { "underline" },
                warnings = { "underline" },
                information = { "underline" },
            },
        },
    },
}

function theme.apply()
    require("catppuccin").setup(theme.opts)
    vim.cmd.colorscheme("catppuccin")
end

function theme.toggle_transparent()
    theme.opts.transparent_background = not theme.opts.transparent_background
    theme.apply()
end

return theme
