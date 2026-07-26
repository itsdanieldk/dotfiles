return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        main = "nvim-treesitter.configs",
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "lua", "vim", "vimdoc", "query",
                "bash",
                "json", "yaml", "toml",
                "markdown", "markdown_inline",
                -- .NET: xml covers .fsproj/.csproj/.props/.targets
                "c_sharp", "fsharp", "xml",
                -- Azure: .bicep templates, and sql for Azure SQL
                "bicep", "sql",
                "html", "css", "javascript", "typescript",
                "dockerfile", "gitignore",
            },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        },
    },
}
