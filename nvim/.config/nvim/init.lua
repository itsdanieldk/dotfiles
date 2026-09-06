vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- ============================================================
-- UI
-- ============================================================
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.laststatus = 3
vim.o.colorcolumn = "100"
vim.o.fillchars = "eob: "
vim.o.splitright = true
vim.o.splitbelow = true


-- ============================================================
-- Editing
-- ============================================================
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.wrap = false
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"


-- ============================================================
-- Search
-- ============================================================
vim.o.ignorecase = true
vim.o.smartcase = true


-- ============================================================
-- Behavior
-- ============================================================
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.o.swapfile = false
vim.o.mouse = "a"
vim.o.confirm = true


-- ============================================================
-- Keymaps
-- ============================================================
local map = vim.keymap.set

map("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })

map("v", "<", "<gv", { desc = "Outdent, keep selection" })
map("v", ">", ">gv", { desc = "Indent, keep selection" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })


-- ============================================================
-- Treesitter
-- ============================================================
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})


-- ============================================================
-- Colorscheme
-- ============================================================
vim.cmd.colorscheme("catppuccin-frappe")
