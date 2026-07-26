return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
        { "<leader>dv", "<cmd>DiffviewOpen<cr>",        desc = "Diffview open" },
        { "<leader>dq", "<cmd>DiffviewClose<cr>",       desc = "Diffview close" },
        { "<leader>dh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview file history" },
    },
}
