return {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = { 'nvim-lua/plenary.nvim' },
    init = function()
        vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
            group = vim.api.nvim_create_augroup('ObsidianConceal', { clear = true }),
            callback = function()
                if vim.bo.filetype == 'markdown' then
                    vim.opt_local.conceallevel = 2
                end
            end,
        })
    end,
    opts = {
        workspaces = {
            { name = 'WorkBrain', path = '~/WorkBrain' },
            { name = 'MyBrain',   path = '~/MyBrain' },
        },
        daily_notes = {
            folder = '0 - inbox',
            date_format = '%Y-%m-%d',
            template = 'Daily',
        },
        templates = {
            folder = '5 - templates',
        },
        completion = {
            nvim_cmp = true,
            min_chars = 2,
        },
        ui = {
            enable = true,
            checkboxes = {
                [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
                ['x'] = { char = '', hl_group = 'ObsidianDone' },
            },
        },
        attachments = { img_folder = 'assets' },
        mappings = {
            ['gf'] = {
                action = function() return require('obsidian').util.gf_passthrough() end,
                opts = { noremap = false, expr = true, buffer = true },
            },
            ['<cr>'] = {
                action = function() return require('obsidian').util.smart_action() end,
                opts = { buffer = true, expr = true },
            },
        },
    },
    keys = {
        { '<leader>on', '<cmd>ObsidianNew<cr>',           desc = '[O]bsidian [N]ew note' },
        { '<leader>od', '<cmd>ObsidianToday<cr>',         desc = '[O]bsidian [D]aily note' },
        { '<leader>os', '<cmd>ObsidianSearch<cr>',        desc = '[O]bsidian [S]earch' },
        { '<leader>of', '<cmd>ObsidianQuickSwitch<cr>',   desc = '[O]bsidian [F]ind note' },
        { '<leader>ob', '<cmd>ObsidianBacklinks<cr>',     desc = '[O]bsidian [B]acklinks' },
        { '<leader>ot', '<cmd>ObsidianTemplate<cr>',      desc = '[O]bsidian [T]emplate' },
        { '<leader>ol', '<cmd>ObsidianLinks<cr>',         desc = '[O]bsidian [L]inks' },
        { '<leader>oo', '<cmd>ObsidianOpen<cr>',          desc = '[O]bsidian [O]pen in app' },
    },
}
