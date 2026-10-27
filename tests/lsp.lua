local spec = dofile('lua/plugins/lsp-config.lua')[1]
local setup_calls = 0

package.loaded['cmp_nvim_lsp'] = {
    default_capabilities = function()
        return { textDocument = { completion = { completionItem = { snippetSupport = true } } } }
    end,
}
package.loaded['mason-lspconfig'] = {
    setup = function(opts)
        setup_calls = setup_calls + 1
        assert(opts.handlers == nil)
        table.sort(opts.ensure_installed)
        assert(vim.deep_equal(opts.ensure_installed, { 'clangd', 'jdtls', 'lua_ls', 'zls' }))
        for _, name in ipairs(opts.ensure_installed) do
            assert(vim.lsp.config[name].capabilities.textDocument.completion.completionItem.snippetSupport)
        end
    end,
}

spec.config()
assert(setup_calls == 1)
assert(vim.deep_equal(vim.lsp.config.clangd.cmd, { 'clangd' }))
assert(vim.lsp.config.lua_ls.settings.Lua.completion.callSnippet == 'Replace')

vim.g.clangd_cmd = { '/custom/clangd', '--background-index' }
spec.config()
assert(vim.deep_equal(vim.lsp.config.clangd.cmd, vim.g.clangd_cmd))

local first = vim.api.nvim_get_current_buf()
local second = vim.api.nvim_create_buf(true, false)
local hints = { [first] = false, [second] = true }
vim.lsp.inlay_hint.is_enabled = function(filter) return hints[filter.bufnr] end
vim.lsp.inlay_hint.enable = function(enabled, filter)
    for buf in pairs(hints) do
        if not filter or filter.bufnr == buf then hints[buf] = enabled end
    end
end
vim.lsp.get_client_by_id = function()
    return {
        supports_method = function(method)
            return method == vim.lsp.protocol.Methods.textDocument_inlayHint
        end,
    }
end
local type_definition = function() end
package.loaded['telescope.builtin'] = setmetatable({ lsp_type_definitions = type_definition }, {
    __index = function() return function() end end,
})
vim.api.nvim_exec_autocmds('LspAttach', { buffer = first, data = { client_id = 1 } })
assert(vim.fn.maparg('gy', 'n', false, true).callback == type_definition)
assert(vim.fn.maparg('\\d', 'n') == '', 'debug prefix must not run type definition')
local toggle = vim.fn.maparg('\\th', 'n', false, true).callback
vim.api.nvim_set_current_buf(second)
toggle()
assert(hints[first] == true and hints[second] == true)
toggle()
assert(hints[first] == false and hints[second] == true, 'toggling must not affect other buffers')

print('LSP configuration tests passed')
