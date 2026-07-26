local opt = vim.opt


-- ============================================================
-- UI
-- ============================================================
-- Line numbers
opt.number = true
opt.relativenumber = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.showmode = false                  -- lualine already shows mode
opt.cmdheight = 0                     -- cleaner UI; cmd line appears only when needed
opt.laststatus = 3                    -- single global statusline
opt.colorcolumn = "100"
opt.fillchars = { eob = " " }         -- hide '~' on empty lines

-- Splits
opt.splitright = true
opt.splitbelow = true


-- ============================================================
-- Editing
-- ============================================================
-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Wrapping
opt.wrap = false
opt.breakindent = true

-- Whitespace
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }


-- ============================================================
-- Search
-- ============================================================
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true


-- ============================================================
-- Behavior
-- ============================================================
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.mouse = "a"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true                    -- :q on dirty buf prompts instead of erroring
