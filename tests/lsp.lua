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

print('LSP configuration tests passed')
