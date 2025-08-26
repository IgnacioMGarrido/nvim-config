return {
    {
        "mason-org/mason.nvim",
        opts = {},
        config = function()
            require("mason").setup()
        end
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "clangd", "jdtls", "zls" }
            })
        end
    },
    {
        url = "https://gitlab.com/jlafarr99/sonarlint.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mason-org/mason.nvim",
        },
        config = function()
            require("sonarlint").setup({
                server = {
                    cmd = {
                        "sonarlint-language-server",
                        "-stdio",
                        "-analyzers",
                        -- SOLO C/C++: usa únicamente el analyzer de C-family
                        vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
                    },
                    -- settings = {
                    --   sonarlint = {
                    --     analyzerProperties = {
                    --       -- if using compilecommands
                    --       ["sonar.cfamily.compile-commands"] =
                    --         vim.fn.getcwd() .. "/build/compile_commands.json",
                    --     },
                    --   },
                    -- },
                },
                -- using on cpp files
                filetypes = { "c", "cpp", "objc", "objcpp" },
            })
        end,
    },

    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
            'williamboman/mason-lspconfig.nvim',
            {
                'whoissethdaniel/mason-tool-installer.nvim',
                opts = {
                    ensure_installed = {
                        'sonarlint-language-server',
                    },
                    run_on_start = true,
                }
            },

            -- useful status updates for lsp.
            -- note: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim',       opts = {} },

            -- allows extra capabilities provided by nvim-cmp
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            vim.api.nvim_create_autocmd('lspattach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    -- note: remember that lua is a real programming language, and as such it is possible
                    -- to define small helper and utility functions so you don't have to repeat yourself.
                    --
                    -- in this case, we create a function that lets us more easily define mappings specific
                    -- for lsp related items. it sets the mode, buffer and description for us each time.
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'lsp: ' .. desc })
                    end

                    -- jump to the definition of the word under your cursor.
                    --  this is where a variable was first declared, or where a function is defined, etc.
                    --  to jump back, press <c-t>.
                    map('gd', require('telescope.builtin').lsp_definitions, '[g]oto [d]efinition')

                    -- find references for the word under your cursor.
                    map('gr', require('telescope.builtin').lsp_references, '[g]oto [r]eferences')

                    -- jump to the implementation of the word under your cursor.
                    --  useful when your language has ways of declaring types without an actual implementation.
                    map('gi', require('telescope.builtin').lsp_implementations, '[g]oto [i]mplementation')

                    -- jump to the type of the word under your cursor.
                    --  useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('<leader>d', require('telescope.builtin').lsp_type_definitions, 'type [d]efinition')

                    -- fuzzy find all the symbols in your current document.
                    --  symbols are things like variables, functions, types, etc.
                    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[d]ocument [s]ymbols')

                    -- fuzzy find all the symbols in your current workspace.
                    --  similar to document symbols, except searches over your entire project.
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[w]orkspace [s]ymbols')

                    -- rename the variable under your cursor.
                    --  most language servers support renaming across files, etc.
                    map('<leader>rn', vim.lsp.buf.rename, '[r]e[n]ame')

                    -- execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your lsp for this to activate.
                    map('<leader>ca', vim.lsp.buf.code_action, '[c]ode [a]ction', { 'n', 'x' })

                    -- warn: this is not goto definition, this is goto declaration.
                    --  for example, in c this would take you to the header.
                    map('gD', vim.lsp.buf.declaration, '[g]oto [d]eclaration')

                    -- the following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    see `:help cursorhold` for information about when this is executed
                    --
                    -- when you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight',
                            { clear = false })
                        vim.api.nvim_create_autocmd({ 'cursorhold', 'cursorholdi' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'cursormoved', 'cursormovedi' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('lspdetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- the following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- this may be unwanted, since they displace some of your code
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[t]oggle inlay [h]ints')
                    end
                end,
            })

            -- change diagnostic symbols in the sign column (gutter)
            if vim.g.have_nerd_font then
                -- local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
                -- local diagnostic_signs = {}
                -- for type, icon in pairs(signs) do
                --   diagnostic_signs[vim.diagnostic.severity[type]] = icon
                -- end
                vim.diagnostic.config {
                    signs = { text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.HINT] = " ",
                        [vim.diagnostic.severity.INFO] = " ",
                    } },
                    underline = false,
                    virtual_text = false,
                    update_in_insert = false,
                    severity_sort = true,
                }
            end

            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics,
                {
                    virtual_text = false,
                })

            local servers = {
                clangd = {
                    settings = {
                        clangd = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                        },
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                        },
                    },
                },
                -- Java
                jdtls = {
                },
                zls = {
                },
            }


            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                'stylua', -- Used to format Lua code
            })
            --  LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

            require('mason-lspconfig').setup {
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        -- This handles overriding only values explicitly passed
                        -- by the server configuration above. Useful when disabling
                        -- certain features of an LSP (for example, turning off formatting for ts_ls)
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        require('lspconfig')[server_name].setup(server)
                    end,
                },
            }
        end
    }
}
