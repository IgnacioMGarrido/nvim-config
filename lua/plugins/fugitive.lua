return {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Gwrite", "Gread", "Gstatus", "Gblame" },
    keys = {
        { "<leader>ms", ":vert Git<CR>",     desc = "Git status (fugitive)" },
        { "<leader>mb", ":Git blame<CR>",    desc = "Git blame" },
        { "<leader>md", ":Gvdiffsplit!<CR>", desc = "Git diff vertical split" },
        {
            "<leader>mD",
            function()
                -- local + remote branches (dedup and filter empty)
                local branches = vim.fn.systemlist(
                    "git for-each-ref --format='%(refname:short)' refs/heads refs/remotes | sort -u"
                )
                if not branches or #branches == 0 then
                    vim.notify("No branches found", vim.log.levels.WARN)
                    return
                end
                vim.ui.select(branches, { prompt = "Diff against branch:" }, function(choice)
                    if choice and choice ~= "" then
                        vim.cmd("Gvdiffsplit! " .. choice)
                    end
                end)
            end,
            desc = "Git diff current file vs selected branch",
        },
        { "<leader>mw", ":Gwrite<CR>", desc = "Git write (stage)" },
    },
    config = function()
        vim.g.fugitive_git_executable = "git"
    end,
}
