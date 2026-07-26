-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
    -- Update checking is off: enabling it fetches from every plugin remote on
    -- each startup. Run :Lazy check (or :Lazy update) by hand instead.
    checker = { enabled = false },
    change_detection = { notify = false },
})
