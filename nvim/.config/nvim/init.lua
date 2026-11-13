vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- ============================================================
-- UI
-- ============================================================
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.signcolumn = "yes"  -- fixed width, so gitsigns doesn't shift the text
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.laststatus = 3
vim.o.colorcolumn = "100"
vim.o.fillchars = "eob: "
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.winborder = "rounded"
vim.o.pumborder = "rounded"
vim.o.pumheight = 10


-- ============================================================
-- Editing
-- ============================================================
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.wrap = false
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.virtualedit = "block"
vim.o.inccommand = "split"

-- Completion from buffer words as you type; no LSP.
vim.o.autocomplete = true
vim.o.completeopt = "menuone,noselect,popup,fuzzy"

-- Folds come from treesitter; foldexpr returns 0 where no parser exists.
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99
vim.o.foldtext = ""


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
vim.o.updatetime = 250


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

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("i", "<Tab>", function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end,
    { expr = true, desc = "Next completion" })
map("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end,
    { expr = true, desc = "Previous completion" })

-- Danish layout: [ and ] need right-Option. remap = true so æq, øb, øh etc. reach the bracket maps.
map({ "n", "x", "o" }, "æ", "[", { remap = true, desc = "[" })
map({ "n", "x", "o" }, "ø", "]", { remap = true, desc = "]" })

vim.cmd.packadd("nvim.undotree")
map("n", "<leader>u", "<cmd>Undotree<CR>", { desc = "Undo tree" })


-- ============================================================
-- Autocommands
-- ============================================================
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.hl.on_yank() end,
})

-- Restore the cursor position (:h restore-cursor). Nested FileType: filetype isn't set yet at BufRead.
vim.api.nvim_create_autocmd("BufRead", {
    callback = function(args)
        vim.api.nvim_create_autocmd("FileType", {
            buffer = args.buf,
            once = true,
            callback = function()
                local ft = vim.bo[args.buf].filetype
                local line = vim.fn.line([['"]])
                if not ft:match("commit") and not ft:match("rebase")
                    and line > 1 and line <= vim.fn.line("$") then
                    vim.cmd([[normal! g`"]])
                end
            end,
        })
    end,
})


-- ============================================================
-- Treesitter
-- ============================================================
vim.treesitter.language.register("eex", "eelixir")
vim.treesitter.language.register("c_sharp", "cs")
vim.treesitter.language.register("git_rebase", "gitrebase")
vim.treesitter.language.register("bash", "sh")

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})


-- ============================================================
-- Plugins (vim.pack; revisions pinned by nvim-pack-lock.json)
-- ============================================================
-- Must be registered before vim.pack.add, or the first install never fires it.
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
            if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
            vim.cmd("TSUpdate")
        end
    end,
})

local gh = function(repo) return "https://github.com/" .. repo end
pcall(vim.pack.add, {
    { src = gh("catppuccin/nvim"), name = "catppuccin" },
    gh("nvim-tree/nvim-web-devicons"),
    gh("nvim-tree/nvim-tree.lua"),
    { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
    gh("lewis6991/gitsigns.nvim"),
    gh("ibhagwan/fzf-lua"),
})

-- nil when an install was declined or failed, so nvim still starts (EDITOR=nvim opens commit messages).
local function plugin(mod)
    local ok, m = pcall(require, mod)
    return ok and m or nil
end

-- --- Colorscheme ---
local catppuccin = plugin("catppuccin")
if catppuccin then
    catppuccin.setup({
        flavour = "frappe",
        integrations = { nvimtree = true, gitsigns = true, fzf = true },
    })
    vim.cmd.colorscheme("catppuccin")
end

-- --- Parsers ---
-- Compiled locally by nvim-treesitter; needs tree-sitter-cli. A no-op for parsers already installed.
local ts = plugin("nvim-treesitter")
if ts and vim.fn.executable("tree-sitter") == 1 then
    ts.install({
        "bash", "c_sharp", "css", "diff", "dockerfile", "eex", "elixir", "elm", "fsharp",
        "git_rebase", "gitcommit", "heex", "html", "javascript", "json", "sql", "toml",
        "typescript", "yaml",
    })
end

-- --- File tree ---
local nvim_tree = plugin("nvim-tree")
if nvim_tree then
    -- Before plugin/ scripts load (after init.lua), or netrw grabs directory buffers first.
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvim_tree.setup({
        hijack_directories = { enable = false },  -- else `nvim <dir>` gets a full-width tree, no edit window
        view = { width = 32 },
        renderer = { group_empty = true, indent_markers = { enable = true } },
        update_focused_file = { enable = true },
        filters = { dotfiles = false, custom = { "^\\.git$" } },
    })
    local tree = require("nvim-tree.api").tree

    map("n", "<leader>e", function() tree.toggle() end, { desc = "Toggle file tree" })
    map("n", "<leader>E", function() tree.find_file({ open = true, focus = true }) end,
        { desc = "Reveal file in tree" })

    -- Open on `nvim` and `nvim <dir>`; stays closed for `nvim <file>` and commit messages.
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(ev)
            if vim.fn.isdirectory(ev.file) == 1 then
                vim.cmd.enew()
                vim.cmd.bwipeout(ev.buf)
                vim.cmd.cd(ev.file)
                tree.open()
            elseif ev.file == "" and vim.bo[ev.buf].buftype == "" then
                tree.open()
            end
        end,
    })

    -- :q in the last file window would otherwise leave nvim open on the tree alone.
    vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
            local wins = vim.tbl_filter(function(w)
                return vim.api.nvim_win_get_config(w).relative == ""
            end, vim.api.nvim_list_wins())
            if #wins == 2 and tree.is_visible() and vim.bo.filetype ~= "NvimTree" then
                tree.close()
            end
        end,
    })
end

-- --- Git signs ---
local gitsigns = plugin("gitsigns")
if gitsigns then
    gitsigns.setup({
        on_attach = function(buf)
            local function m(lhs, rhs, desc) map("n", lhs, rhs, { buffer = buf, desc = desc }) end
            m("]h", function() gitsigns.nav_hunk("next") end, "Next hunk")
            m("[h", function() gitsigns.nav_hunk("prev") end, "Previous hunk")
            m("<leader>hs", gitsigns.stage_hunk, "Stage hunk")
            m("<leader>hr", gitsigns.reset_hunk, "Reset hunk")
            m("<leader>hp", gitsigns.preview_hunk, "Preview hunk")
            m("<leader>hb", function() gitsigns.blame_line({ full = true }) end, "Blame line")
        end,
    })
end

-- --- Fuzzy finder ---
local fzf = plugin("fzf-lua")
if fzf then
    fzf.setup({})
    map("n", "<leader>f", fzf.files, { desc = "Find files" })
    map("n", "<leader>/", fzf.live_grep, { desc = "Grep" })
    map("n", "<leader>b", fzf.buffers, { desc = "Buffers" })
    map("n", "<leader>r", fzf.oldfiles, { desc = "Recent files" })
end


-- ============================================================
-- Statusline
-- ============================================================
function _G.StatuslineGit()
    local head = vim.b.gitsigns_head
    if not head or head == "" then return "" end
    local status = vim.b.gitsigns_status or ""
    return (" %s%s  "):format(head, status ~= "" and " " .. status or "")
end

vim.o.statusline = " %f %m%r%=%{v:lua.StatuslineGit()}%y  %l:%c  %P "
