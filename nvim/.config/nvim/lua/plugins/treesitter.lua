return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "lua", "vim", "vimdoc", "query",
                "bash", "zsh",
                "json", "yaml", "toml",
                "markdown", "markdown_inline",
                "c_sharp", "html", "css", "javascript", "typescript",
                "dockerfile", "gitignore",
            },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        },
    },
}
