return {
    "stevearc/oil.nvim",
    ---@type oil.SetupOpts
    opts = {
        columns = { "icon" },
        default_file_explorer = true,
        view_options = {
            show_hidden = false,
        },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function(_, opts)
        require("oil").setup(opts)
        vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Oil: open parent directory" })
        vim.keymap.set("n", "<leader>E", function()
            require("oil").open(vim.fn.getcwd())
        end, { desc = "Oil: open project root" })
    end,
}
