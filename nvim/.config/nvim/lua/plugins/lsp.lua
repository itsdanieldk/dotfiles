return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                            diagnostics = { globals = { "vim" } },
                        },
                    },
                },
                bashls = {},
                jsonls = {},
                yamlls = {},
                dockerls = {},
                marksman = {},
                ts_ls = {},
            }

            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_keys(servers),
                automatic_installation = true,
                automatic_enable = true,
            })

            require("mason-tool-installer").setup({
                ensure_installed = {
                    "stylua",
                    "prettierd",
                    "shfmt",
                },
            })

            local capabilities = require("blink.cmp").get_lsp_capabilities()
            vim.lsp.config("*", { capabilities = capabilities })
            for name, opts in pairs(servers) do
                if next(opts) ~= nil then
                    vim.lsp.config(name, opts)
                end
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local buf = args.buf
                    local map = function(mode, keys, fn, desc)
                        vim.keymap.set(mode, keys, fn, { buffer = buf, desc = desc })
                    end
                    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
                    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                    map("n", "gr", vim.lsp.buf.references, "References")
                    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
                    map("n", "gt", vim.lsp.buf.type_definition, "Type definition")
                    map("n", "K", vim.lsp.buf.hover, "Hover")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("n", "<leader>sd", vim.lsp.buf.document_symbol, "Document symbols")
                end,
            })

            -- To add C# / F# support later:
            --   C#: install seblj/roslyn.nvim (Mason package: "roslyn")
            --   F#: install ionide/Ionide-vim (no Mason package; needs dotnet tool fsautocomplete)
        end,
    },
}
